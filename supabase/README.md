Supabase DB for PremiumMatcher
==============================

This directory contains SQL migrations to bootstrap a Supabase Postgres database for the matching API.

Migrations
----------
1. `0001_enable_extensions.sql` – enables `pg_trgm` and `unaccent`.
2. `0002_schema.sql` – creates `dss_individuals`, `matches`, and a simple `match_status_view`.
3. `0003_functions.sql` – creates `public.search_candidates(...)` used by the API `/api/search` endpoint.

Apply
-----
If you use the Supabase CLI:
```
supabase db push
```

Otherwise, run the SQL files in order against your Supabase Postgres database.

Notes
-----
- Weights and scoring in `search_candidates` are tunable. Consider calibrating on your data.
- Add RLS policies as needed. For local dev, you can keep RLS disabled; for production, protect `matches` and PII.

