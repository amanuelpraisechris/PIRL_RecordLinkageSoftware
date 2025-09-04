-- Search function inspired by PIRL’s parameter set

create or replace function public.search_candidates(
    _first_name text default null,
    _middle_name text default null,
    _last_name text default null,
    _tl_first_name text default null,
    _tl_middle_name text default null,
    _tl_last_name text default null,
    _gender text default null,
    _bday text default null,
    _bmonth text default null,
    _byear text default null,
    _village text default null,
    _subvillage text default null,
    _use_first_name boolean default true,
    _use_middle_name boolean default false,
    _use_last_name boolean default true,
    _use_tl_first_name boolean default false,
    _use_tl_middle_name boolean default false,
    _use_tl_last_name boolean default false,
    _use_gender boolean default false,
    _use_bday boolean default false,
    _use_bmonth boolean default false,
    _use_byear boolean default true,
    _use_village boolean default false,
    _use_subvillage boolean default false
)
returns table (
    dss_id text,
    birth_year text,
    score double precision,
    rank_no_gap int,
    rank_gap int,
    row_number int,
    name_score double precision,
    location text,
    first_name text,
    middle_name text,
    last_name text,
    gender text
)
language sql stable as $$
with q as (
  select
    di.dss_id,
    di.birth_year,
    di.first_name,
    di.middle_name,
    di.last_name,
    di.gender,
    di.location,
    -- Unaccented, concatenated names for similarity
    unaccent(coalesce(di.first_name,'') || ' ' || coalesce(di.middle_name,'') || ' ' || coalesce(di.last_name,'')) as nm,
    unaccent(coalesce(di.tl_first_name,'') || ' ' || coalesce(di.tl_middle_name,'') || ' ' || coalesce(di.tl_last_name,'')) as tlnm
  from public.dss_individuals di
)
, inputs as (
  select
    unaccent(trim(coalesce(_first_name,'') || ' ' || coalesce(_middle_name,'') || ' ' || coalesce(_last_name,''))) as nm,
    unaccent(trim(coalesce(_tl_first_name,'') || ' ' || coalesce(_tl_middle_name,'') || ' ' || coalesce(_tl_last_name,''))) as tlnm
)
, scored as (
  select
    q.*, 
    -- individual similarities (0..1)
    (case when _use_first_name then similarity(unaccent(coalesce(_first_name,'')), unaccent(coalesce(q.first_name,''))) else 0 end) as sim_fn,
    (case when _use_middle_name then similarity(unaccent(coalesce(_middle_name,'')), unaccent(coalesce(q.middle_name,''))) else 0 end) as sim_mn,
    (case when _use_last_name then similarity(unaccent(coalesce(_last_name,'')), unaccent(coalesce(q.last_name,''))) else 0 end) as sim_ln,
    (case when _use_tl_first_name then similarity(unaccent(coalesce(_tl_first_name,'')), unaccent(coalesce(split_part(q.tlnm,' ',1)))) else 0 end) as sim_tlfn,
    (case when _use_tl_middle_name then similarity(unaccent(coalesce(_tl_middle_name,'')), unaccent(coalesce(split_part(q.tlnm,' ',2)))) else 0 end) as sim_tlmn,
    (case when _use_tl_last_name then similarity(unaccent(coalesce(_tl_last_name,'')), unaccent(coalesce(split_part(q.tlnm,' ',3)))) else 0 end) as sim_tlln,
    (case when _use_gender and _gender is not null and q.gender is not null and lower(_gender)=lower(q.gender) then 1.0 else 0 end) as sim_gender,
    (case when _use_bday and _bday is not null and q.gender is not null then 0.1 else 0 end) as sim_bday, -- placeholder weight
    (case when _use_bmonth and _bmonth is not null and q.gender is not null then 0.1 else 0 end) as sim_bmonth, -- placeholder weight
    (case when _use_byear and _byear is not null and q.birth_year is not null then greatest(0, 1 - (abs(coalesce(_byear,'0')::int - coalesce(q.birth_year,'0')::int)::numeric / 10))::double precision else 0 end) as sim_byear,
    (case when _use_village and _village is not null then similarity(unaccent(_village), unaccent(coalesce(q.location,''))) else 0 end) as sim_village,
    (case when _use_subvillage and _subvillage is not null then similarity(unaccent(_subvillage), unaccent(coalesce(q.location,''))) else 0 end) as sim_subvillage,
    similarity((select nm from inputs), q.nm) as name_score
  from q
)
select
  dss_id,
  birth_year,
  -- Weighted score (tune weights as needed)
  (
    0.35*sim_fn + 0.15*sim_mn + 0.35*sim_ln +
    0.05*sim_tlfn + 0.05*sim_tlmn + 0.05*sim_tlln +
    0.10*sim_gender + 0.10*sim_byear + 0.05*sim_village + 0.05*sim_subvillage +
    0.25*name_score
  ) as score,
  dense_rank() over (order by (
    0.35*sim_fn + 0.15*sim_mn + 0.35*sim_ln + 0.05*sim_tlfn + 0.05*sim_tlmn + 0.05*sim_tlln + 0.10*sim_gender + 0.10*sim_byear + 0.05*sim_village + 0.05*sim_subvillage + 0.25*name_score
  ) desc) as rank_no_gap,
  dense_rank() over (order by (
    0.35*sim_fn + 0.15*sim_mn + 0.35*sim_ln + 0.10*sim_gender + 0.10*sim_byear + 0.25*name_score
  ) desc) as rank_gap,
  row_number() over (order by (
    0.35*sim_fn + 0.15*sim_mn + 0.35*sim_ln + 0.05*sim_tlfn + 0.05*sim_tlmn + 0.05*sim_tlln + 0.10*sim_gender + 0.10*sim_byear + 0.05*sim_village + 0.05*sim_subvillage + 0.25*name_score
  ) desc) as row_number,
  name_score,
  location,
  first_name,
  middle_name,
  last_name,
  gender
from scored
order by score desc, dss_id
limit 200;
$$;

