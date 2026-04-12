-- readings 보안 강화: user_id NOT NULL 제약 + INSERT 정책 재작성

-- 기존 INSERT 정책 삭제 (user_id is null 허용하던 것)
drop policy if exists "readings_insert_own" on public.readings;

-- user_id NOT NULL 제약 추가 (게스트 저장 불가 — 클라이언트 보관만 허용)
alter table public.readings
  alter column user_id set not null;

-- 강화된 INSERT 정책: 반드시 자신의 user_id만
create policy "readings_insert_own"
  on public.readings for insert
  to authenticated
  with check (auth.uid() = user_id);

-- deleteAccount cascade를 위한 readings 삭제 정책 명시
-- (이미 user_id FK → auth.users ON DELETE CASCADE 이므로 Edge Function에서도 동작)
comment on policy "readings_insert_own" on public.readings
  is '인증된 사용자만 자신의 user_id로만 INSERT 가능 (익명 주입 방지)';
