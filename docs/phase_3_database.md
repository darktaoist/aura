# Phase 3 — data-modeler + schema-validator + migration-manager 산출물
> DDL · RLS · pgvector 인덱스 · 마이그레이션 스크립트
> 에이전트: `data-modeler`, `schema-validator`, `migration-manager` | 날짜: 2026-04-12

---

## 1. ERD (Entity Relationship Diagram)

```
auth.users (Supabase 내장)
     │ 1
     │
     ├──────────── profiles (1:1)
     │              id (FK → auth.users)
     │              display_name
     │              locale
     │              created_at
     │
     └──────────── readings (1:N)
                   id (UUID PK)
                   user_id (FK → auth.users, nullable — 비로그인 허용)
                   type  ENUM('face','palm')
                   image_path
                   landmarks  JSONB
                   features   JSONB
                   result_text
                   model_used ENUM('E2B','E4B')
                   locale     ENUM('ko','en','ja','zh')
                   created_at

physiognomy_kb  (독립, pgvector)
    id bigserial PK
    topic  text
    content text
    embedding vector(768)

palmistry_kb  (독립, pgvector)
    (동일 구조)
```

---

## 2. DDL (Supabase / PostgreSQL)

### 2.1 Extension

```sql
-- 001_extensions.sql
create extension if not exists "uuid-ossp";
create extension if not exists vector;
```

### 2.2 profiles 테이블

```sql
-- 002_profiles.sql
create table public.profiles (
  id          uuid primary key references auth.users on delete cascade,
  display_name text,
  locale      text not null default 'ko'
                check (locale in ('ko', 'en', 'ja', 'zh')),
  created_at  timestamptz not null default now()
);

comment on table  public.profiles is '사용자 프로필 (auth.users 1:1 연장)';
comment on column public.profiles.locale is '앱 표시 언어 (ko/en/ja/zh)';

-- 신규 사용자 자동 프로필 생성 트리거
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, locale)
  values (new.id, coalesce(new.raw_user_meta_data->>'locale', 'ko'));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

### 2.3 readings 테이블

```sql
-- 003_readings.sql
create table public.readings (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users on delete cascade,
                -- nullable: 비로그인 분석은 user_id=null 허용
  type        text not null check (type in ('face', 'palm')),
  image_path  text,            -- Storage path: readings/{user_id}/{uuid}.jpg
  landmarks   jsonb not null,  -- MediaPipe 468점 (face) / 21점 (palm) 좌표
  features    jsonb,           -- 파생 지표 (eye_span, face_height, nose_ratio, ...)
  result_text text not null,
  model_used  text check (model_used in ('E2B', 'E4B')),
  locale      text check (locale in ('ko', 'en', 'ja', 'zh')),
  created_at  timestamptz not null default now()
);

-- 조회 성능을 위한 인덱스
create index idx_readings_user_id   on public.readings (user_id);
create index idx_readings_type      on public.readings (type);
create index idx_readings_created   on public.readings (created_at desc);

comment on table  public.readings is '관상/손금 분석 결과';
comment on column public.readings.landmarks  is 'MediaPipe 랜드마크 좌표 배열';
comment on column public.readings.features   is '파생 지표: eye_span, face_height, nose_ratio, mouth_width, symmetry';
comment on column public.readings.image_path is 'Supabase Storage 경로 (저장 액션 시에만 업로드)';
```

### 2.4 지식 베이스 테이블 (pgvector)

```sql
-- 004_knowledge_base.sql
create table public.physiognomy_kb (
  id        bigserial primary key,
  topic     text not null,       -- 예: '눈 형태', '이마', '코'
  content   text not null,       -- 관상학 지식 청크 (300~500자)
  embedding vector(768)          -- text-embedding-3-small (dim=768)
);

create table public.palmistry_kb (
  like public.physiognomy_kb including all
);

-- IVFFlat 인덱스 (초기 데이터 적재 후 생성)
-- lists 파라미터: rows / 1000 이상 데이터 시 √rows 권장, 초기 100으로 시작
create index idx_physiognomy_kb_embedding
  on public.physiognomy_kb
  using ivfflat (embedding vector_cosine_ops)
  with (lists = 100);

create index idx_palmistry_kb_embedding
  on public.palmistry_kb
  using ivfflat (embedding vector_cosine_ops)
  with (lists = 100);

comment on table  public.physiognomy_kb is '관상학 RAG 지식 베이스';
comment on table  public.palmistry_kb   is '손금학 RAG 지식 베이스';
```

---

## 3. RLS (Row Level Security) 정책

### 3.1 profiles RLS

```sql
-- 005_rls_profiles.sql
alter table public.profiles enable row level security;

-- 본인만 조회/수정
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id);
```

### 3.2 readings RLS

```sql
-- 006_rls_readings.sql
alter table public.readings enable row level security;

-- 본인 레코드만 조회
create policy "readings_select_own"
  on public.readings for select
  using (auth.uid() = user_id);

-- INSERT: 본인 user_id 또는 null (비로그인 분석 저장은 서버서만)
create policy "readings_insert_own"
  on public.readings for insert
  with check (user_id is null or auth.uid() = user_id);

-- DELETE: 본인만
create policy "readings_delete_own"
  on public.readings for delete
  using (auth.uid() = user_id);
```

### 3.3 지식 베이스 RLS

```sql
-- 007_rls_knowledge_base.sql
alter table public.physiognomy_kb enable row level security;
alter table public.palmistry_kb   enable row level security;

-- anon 포함 모든 인증 사용자 SELECT 허용
create policy "kb_select_all"
  on public.physiognomy_kb for select
  to anon, authenticated
  using (true);

create policy "kb_select_all"
  on public.palmistry_kb for select
  to anon, authenticated
  using (true);

-- INSERT/UPDATE/DELETE: service_role 전용 (Edge Function에서만)
-- service_role은 RLS 우회하므로 별도 정책 불필요
```

---

## 4. Storage Bucket 설정

```sql
-- 008_storage.sql
-- (Supabase 대시보드 또는 Management API로 실행)

-- bucket 생성
insert into storage.buckets (id, name, public)
values ('readings', 'readings', false);  -- private bucket

-- Storage RLS: 본인 폴더만 업로드/조회
create policy "readings_storage_insert_own"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'readings' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "readings_storage_select_own"
  on storage.objects for select
  to authenticated
  using (bucket_id = 'readings' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "readings_storage_delete_own"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'readings' and (storage.foldername(name))[1] = auth.uid()::text);
```

---

## 5. 마이그레이션 파일 체계

```
supabase/migrations/
├── 20260412000001_extensions.sql
├── 20260412000002_profiles.sql
├── 20260412000003_readings.sql
├── 20260412000004_knowledge_base.sql
├── 20260412000005_rls_profiles.sql
├── 20260412000006_rls_readings.sql
├── 20260412000007_rls_knowledge_base.sql
└── 20260412000008_storage.sql
```

**파일명 규칙**: `YYYYMMDDHHMMSS_description.sql`

**적용 명령**
```bash
# Supabase CLI
supabase db push

# 롤백 (개발 환경)
supabase db reset
```

---

## 6. 롤백 전략

### 6.1 프로덕션 무중단 롤백 원칙

1. **테이블 삭제 금지** — `ALTER TABLE ... DROP COLUMN` 대신 nullable 컬럼으로 두고 신규 마이그레이션에서 처리
2. **인덱스 생성** — `CREATE INDEX CONCURRENTLY` 사용 (잠금 없음)
3. **트리거 변경** — 신규 트리거 추가 후 구 트리거 삭제 순서

### 6.2 롤백 스크립트 (`rollback/` 별도 관리)

```sql
-- rollback/20260412_rollback.sql
drop index if exists idx_physiognomy_kb_embedding;
drop index if exists idx_palmistry_kb_embedding;
drop table if exists public.palmistry_kb;
drop table if exists public.physiognomy_kb;
drop table if exists public.readings;
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user();
drop table if exists public.profiles;
```

---

## 7. JSONB 스키마 명세

### 7.1 `readings.landmarks` (face)

```json
{
  "landmarks": [
    { "x": 0.512, "y": 0.234, "z": -0.012 },  // index 0
    // ... 468개
  ],
  "score": 0.987,
  "frame_width": 640,
  "frame_height": 480
}
```

### 7.2 `readings.features` (face)

```json
{
  "eye_span": 0.182,
  "face_height": 0.645,
  "nose_ratio": 0.553,
  "mouth_width": 0.213,
  "symmetry": 0.042,
  "forehead_height": 0.142,
  "eyebrow_distance": 0.051
}
```

### 7.3 `readings.landmarks` (palm)

```json
{
  "landmarks": [
    { "x": 0.5, "y": 0.8, "z": 0.0 },  // index 0 (손목)
    // ... 21개
  ],
  "handedness": "Left",  // "Left" | "Right"
  "score": 0.95
}
```

---

## 8. 스키마 검증 체크리스트 (schema-validator)

| 항목 | 확인 |
|---|---|
| PK는 모두 NOT NULL | ✅ uuid/bigserial |
| FK 삭제 정책 | ✅ ON DELETE CASCADE (profiles, readings) |
| CHECK 제약조건 | ✅ type, model_used, locale ENUM 검증 |
| NULL 허용 필드 명시 | ✅ readings.user_id nullable (비로그인) |
| 인덱스 중복 없음 | ✅ 각 테이블 독립 인덱스 |
| vector 차원 일치 | ✅ embedding vector(768) — text-embedding-3-small 출력 dim |
| RLS 활성화 | ✅ 모든 public 테이블 |
| Storage bucket private | ✅ public=false |
| service_role key 미노출 | ✅ Edge Function 환경변수 전용 |
| 트리거 security definer | ✅ handle_new_user() |

---

## 9. 다음 단계 (Phase 4) 입력 사항

Phase 4 (`token-designer` + `ux-designer` + `style-inspector`)에서:

1. Aura 디자인 토큰: 화이트 베이스 · 부드러운 그라데이션 포인트
2. `flex_color_scheme` 시드 컬러 선정
3. `google_fonts` 선택 (KO/JA/ZH 지원 폰트 필수)
4. Light/Dark ColorScheme 토큰 매핑
5. 핵심 컴포넌트 UX: 카메라 오버레이, 섹션 카드, 진행률 UI

---

*Phase 3 완료: 2026-04-12*
