-- Rollback: drop all Phase 3 objects (dev/staging only)
drop index if exists idx_physiognomy_kb_embedding;
drop index if exists idx_palmistry_kb_embedding;
drop table if exists public.palmistry_kb;
drop table if exists public.physiognomy_kb;
drop index if exists idx_readings_created;
drop index if exists idx_readings_type;
drop index if exists idx_readings_user_id;
drop table if exists public.readings;
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user();
drop table if exists public.profiles;
