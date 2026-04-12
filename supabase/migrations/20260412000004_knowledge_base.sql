-- Knowledge base tables for RAG
create table public.physiognomy_kb (
  id        bigserial primary key,
  topic     text not null,
  content   text not null,
  embedding vector(768)
);

create table public.palmistry_kb (
  like public.physiognomy_kb including all
);

-- IVFFlat index (create after initial data load)
create index idx_physiognomy_kb_embedding
  on public.physiognomy_kb
  using ivfflat (embedding vector_cosine_ops)
  with (lists = 100);

create index idx_palmistry_kb_embedding
  on public.palmistry_kb
  using ivfflat (embedding vector_cosine_ops)
  with (lists = 100);

comment on table public.physiognomy_kb is '관상학 RAG 지식 베이스';
comment on table public.palmistry_kb   is '손금학 RAG 지식 베이스';
