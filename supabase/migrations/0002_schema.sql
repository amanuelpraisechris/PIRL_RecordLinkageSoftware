-- Core tables (simplified for initial port)

create table if not exists public.dss_individuals (
  id uuid primary key default gen_random_uuid(),
  dss_id text unique not null,
  first_name text,
  middle_name text,
  last_name text,
  tl_first_name text,
  tl_middle_name text,
  tl_last_name text,
  gender text,
  birth_day text,
  birth_month text,
  birth_year text,
  village text,
  subvillage text,
  location text generated always as (coalesce(village,'') || ' / ' || coalesce(subvillage,'')) stored
);

create index if not exists idx_dss_individuals_names on public.dss_individuals using gin ((unaccent(coalesce(first_name,'') || ' ' || coalesce(middle_name,'') || ' ' || coalesce(last_name,''))) gin_trgm_ops);
create index if not exists idx_dss_individuals_tlnames on public.dss_individuals using gin ((unaccent(coalesce(tl_first_name,'') || ' ' || coalesce(tl_middle_name,'') || ' ' || coalesce(tl_last_name,''))) gin_trgm_ops);

create table if not exists public.matches (
  id bigserial primary key,
  record_no text not null,
  facility text not null,
  unique_ctcid_number text,
  tgr_form_number text,
  file_ref text,
  ctc_infant text,
  unique_htc text,
  unique_anc text,
  anc_infant text,
  heid_infant text,
  search_criteria text,
  dss_id text not null references public.dss_individuals(dss_id),
  score double precision not null,
  rank_gap int not null,
  rank_no_gap int not null,
  row_number int not null,
  status text default 'LINKED',
  comment text,
  created_at timestamptz not null default now()
);

create or replace view public.match_status_view as
select
  m.facility,
  m.unique_ctcid_number,
  m.tgr_form_number,
  m.file_ref,
  m.ctc_infant,
  m.unique_htc,
  m.unique_anc,
  m.anc_infant,
  m.heid_infant,
  m.status,
  m.comment,
  m.created_at
from public.matches m;

