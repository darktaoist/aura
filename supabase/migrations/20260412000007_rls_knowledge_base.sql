-- RLS: knowledge base (read-only for anon/authenticated)
alter table public.physiognomy_kb enable row level security;
alter table public.palmistry_kb   enable row level security;

create policy "kb_select_all"
  on public.physiognomy_kb for select
  to anon, authenticated
  using (true);

create policy "kb_select_all"
  on public.palmistry_kb for select
  to anon, authenticated
  using (true);
