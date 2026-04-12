-- RLS: readings
alter table public.readings enable row level security;

create policy "readings_select_own"
  on public.readings for select
  using (auth.uid() = user_id);

create policy "readings_insert_own"
  on public.readings for insert
  with check (user_id is null or auth.uid() = user_id);

create policy "readings_delete_own"
  on public.readings for delete
  using (auth.uid() = user_id);
