PremiumMatcher.Api
==================

Backend API for a premium record matching app inspired by PIRL, using Supabase (Postgres) as the backend.

Quick Start
-----------
- Prereqs: .NET 9 SDK, a Supabase project with database access.
- Set env var `SUPABASE_DB_URL` to your Supabase Postgres connection string (service role recommended for local dev).

Run
---
```
cd PremiumMatcher/PremiumMatcher.Api
dotnet run
```
OpenAPI is available in Development at `/openapi/v1.json`.

Endpoints
---------
- POST `/api/search` → calls Postgres function `public.search_candidates(...)`, returns candidate matches with scores.
- POST `/api/matches` → inserts a confirmed match into `public.matches`.
- POST `/api/matches/exists` → checks whether a clinic-id combination already exists in `public.matches`.
- POST `/api/match-status` → summarizes status via `public.match_status_view`.

Supabase Schema
---------------
See `../../supabase/migrations` for SQL to:
- Enable extensions (pg_trgm, unaccent)
- Create tables (`dss_individuals`, `matches`)
- Create `search_candidates` function and `match_status_view`

Notes
-----
- The matching logic is implemented in Postgres SQL using trigram similarity and weighted scoring; adjust weights as needed.
- Secure the connection string via environment variables or Secrets Manager in production.

