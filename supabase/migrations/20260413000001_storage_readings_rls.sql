-- Storage: readings 버킷 생성 및 RLS 정책
-- 사용자는 자신의 폴더({userId}/)에만 접근 가능

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'readings',
  'readings',
  false,
  10485760,  -- 10MB
  array['image/jpeg', 'image/png']
)
on conflict (id) do nothing;

-- 인증된 사용자 자신의 폴더에만 CRUD 허용
create policy "readings_owner_select"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'readings'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "readings_owner_insert"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'readings'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "readings_owner_update"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'readings'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "readings_owner_delete"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'readings'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
