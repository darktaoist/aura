-- profiles table
create table public.profiles (
  id           uuid primary key references auth.users on delete cascade,
  display_name text,
  locale       text not null default 'ko'
                 check (locale in ('ko', 'en', 'ja', 'zh')),
  created_at   timestamptz not null default now()
);

comment on table  public.profiles is '사용자 프로필 (auth.users 1:1 연장)';
comment on column public.profiles.locale is '앱 표시 언어 (ko/en/ja/zh)';

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
