-- readings table
create table public.readings (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users on delete cascade,
  type        text not null check (type in ('face', 'palm')),
  image_path  text,
  landmarks   jsonb not null,
  features    jsonb,
  result_text text not null,
  model_used  text check (model_used in ('E2B', 'E4B')),
  locale      text check (locale in ('ko', 'en', 'ja', 'zh')),
  created_at  timestamptz not null default now()
);

create index idx_readings_user_id on public.readings (user_id);
create index idx_readings_type    on public.readings (type);
create index idx_readings_created on public.readings (created_at desc);

comment on table  public.readings is '관상/손금 분석 결과';
comment on column public.readings.landmarks  is 'MediaPipe 랜드마크 좌표 배열';
comment on column public.readings.features   is '파생 지표: eye_span, face_height, nose_ratio, mouth_width, symmetry';
comment on column public.readings.image_path is 'Supabase Storage 경로 (저장 액션 시에만 업로드)';
