-- Ethiopian HDSS Adaptations
-- This migration adds Ethiopian-specific fields and structures
-- Apply after 0001, 0002, and 0003

-- ============================================================================
-- PART 1: ETHIOPIAN NAME STRUCTURE
-- ============================================================================

-- Add Ethiopian name fields
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS grandfather_name text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS grandfather_name_amharic text;

-- Rename existing fields for clarity (in new deployments)
-- In existing deployments, map: first_name_amharic = first_name, etc.
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS first_name_amharic text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS father_name_amharic text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS first_name_latin text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS father_name_latin text;

-- Create index for Amharic names (supports UTF-8 Ge'ez script)
CREATE INDEX IF NOT EXISTS idx_dss_amharic_names
ON public.dss_individuals USING gin (
    (coalesce(first_name_amharic,'') || ' ' ||
     coalesce(father_name_amharic,'') || ' ' ||
     coalesce(grandfather_name_amharic,''))
    gin_trgm_ops
);

-- ============================================================================
-- PART 2: ETHIOPIAN ADMINISTRATIVE DIVISIONS
-- ============================================================================

-- Add Ethiopian administrative hierarchy
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS region text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS zone text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS woreda text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS kebele text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS gott text; -- sub-kebele village

-- Create indexes for location-based searches
CREATE INDEX IF NOT EXISTS idx_kebele ON public.dss_individuals(kebele);
CREATE INDEX IF NOT EXISTS idx_woreda ON public.dss_individuals(woreda);
CREATE INDEX IF NOT EXISTS idx_region ON public.dss_individuals(region);

-- Update location generated column to use Ethiopian hierarchy
-- Note: If location column already exists, drop it first
ALTER TABLE public.dss_individuals DROP COLUMN IF EXISTS location;
ALTER TABLE public.dss_individuals ADD COLUMN location text
    GENERATED ALWAYS AS (
        coalesce(region,'') || ' / ' ||
        coalesce(woreda,'') || ' / ' ||
        coalesce(kebele,'') || ' / ' ||
        coalesce(gott,'')
    ) STORED;

-- ============================================================================
-- PART 3: ETHIOPIAN CALENDAR SUPPORT
-- ============================================================================

-- Add Ethiopian calendar fields
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS calendar_type text DEFAULT 'gregorian';
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS birth_day_ethiopian text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS birth_month_ethiopian text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS birth_year_ethiopian text;

-- Ethiopian to Gregorian date conversion function
-- Simplified algorithm - use full implementation in production
CREATE OR REPLACE FUNCTION ethiopian_to_gregorian_year(eth_year text)
RETURNS int AS $$
BEGIN
    -- Ethiopian year is approximately 7-8 years behind Gregorian
    -- Eth 2017 = Greg 2024/2025 (depending on month)
    IF eth_year IS NULL OR eth_year = '' THEN
        RETURN NULL;
    END IF;
    RETURN eth_year::int + 7; -- Simplified conversion
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- PART 4: ETHIOPIAN HEALTH SYSTEM INTEGRATION
-- ============================================================================

-- Health facility types in Ethiopian context
DO $$ BEGIN
    CREATE TYPE health_facility_type AS ENUM (
        'PRIMARY_HOSPITAL',      -- Woreda-level
        'HEALTH_CENTER',         -- Kebele-level
        'HEALTH_POST',           -- Village-level
        'TERTIARY_HOSPITAL',     -- Regional referral
        'GENERAL_HOSPITAL',      -- Zonal
        'PRIVATE_CLINIC',
        'NGO_CLINIC'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Add Ethiopian health facility fields
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS facility_type health_facility_type;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS facility_region text;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS facility_woreda text;

-- Replace Tanzania-specific IDs with Ethiopian health system IDs
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS emr_number text;           -- Electronic Medical Record
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS art_number text;           -- ART ID
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS tb_registration_number text;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS pmtct_id text;             -- PMTCT
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS hiv_testing_id text;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS smartcare_id text;         -- SmartCare EMR
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS maternal_child_id text;    -- MCH

-- ============================================================================
-- PART 5: HOUSEHOLD TRACKING
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.households (
    household_id text PRIMARY KEY,
    region text,
    woreda text,
    kebele text,
    gott text,
    house_number text,
    head_of_household_dss_id text REFERENCES public.dss_individuals(dss_id),
    creation_date date DEFAULT CURRENT_DATE,
    last_updated timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.household_members (
    id bigserial PRIMARY KEY,
    household_id text REFERENCES public.households(household_id),
    dss_id text REFERENCES public.dss_individuals(dss_id),
    relationship_to_head text, -- spouse, child, parent, sibling, other
    join_date date,
    leave_date date,
    residence_status text, -- permanent, temporary, migrated
    UNIQUE(household_id, dss_id, join_date)
);

CREATE INDEX IF NOT EXISTS idx_household_members_dss_id
    ON public.household_members(dss_id);
CREATE INDEX IF NOT EXISTS idx_household_members_household_id
    ON public.household_members(household_id);

-- ============================================================================
-- PART 6: VITAL EVENTS TRACKING
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.vital_events (
    id bigserial PRIMARY KEY,
    dss_id text NOT NULL REFERENCES public.dss_individuals(dss_id),
    event_type text NOT NULL, -- BIRTH, DEATH, MIGRATION_IN, MIGRATION_OUT, MARRIAGE, PREGNANCY
    event_date date,
    event_date_ethiopian text,
    event_location_kebele text,
    registered_by text,
    registration_date timestamptz DEFAULT now(),
    verified boolean DEFAULT false,
    notes text,
    CHECK (event_type IN ('BIRTH', 'DEATH', 'MIGRATION_IN', 'MIGRATION_OUT', 'MARRIAGE', 'PREGNANCY'))
);

CREATE INDEX IF NOT EXISTS idx_vital_events_dss_id ON public.vital_events(dss_id);
CREATE INDEX IF NOT EXISTS idx_vital_events_type ON public.vital_events(event_type);
CREATE INDEX IF NOT EXISTS idx_vital_events_date ON public.vital_events(event_date);

-- ============================================================================
-- PART 7: AUDIT LOGGING
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.audit_log (
    id bigserial PRIMARY KEY,
    user_email text NOT NULL,
    action text NOT NULL, -- SEARCH, MATCH_ASSIGN, MATCH_UPDATE, EXPORT, VITAL_EVENT
    dss_id text,
    clinic_id text,
    ip_address inet,
    timestamp timestamptz DEFAULT now(),
    details jsonb
);

CREATE INDEX IF NOT EXISTS idx_audit_log_user ON public.audit_log(user_email);
CREATE INDEX IF NOT EXISTS idx_audit_log_timestamp ON public.audit_log(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_action ON public.audit_log(action);

-- Audit trigger for match assignments
CREATE OR REPLACE FUNCTION log_match_assignment()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.audit_log (user_email, action, dss_id, clinic_id, details)
    VALUES (
        coalesce(current_setting('app.current_user', true), 'system'),
        'MATCH_ASSIGN',
        NEW.dss_id,
        NEW.record_no,
        to_jsonb(NEW)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS match_assignment_audit ON public.matches;
CREATE TRIGGER match_assignment_audit
    AFTER INSERT ON public.matches
    FOR EACH ROW EXECUTE FUNCTION log_match_assignment();

-- ============================================================================
-- PART 8: QUALITY CONTROL
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.match_quality_metrics (
    id bigserial PRIMARY KEY,
    date date DEFAULT CURRENT_DATE,
    kebele text,
    total_searches int DEFAULT 0,
    matches_with_score_high int DEFAULT 0,      -- score >= 0.8
    matches_with_score_medium int DEFAULT 0,    -- 0.5 <= score < 0.8
    matches_with_score_low int DEFAULT 0,       -- score < 0.5
    manual_review_required int DEFAULT 0,
    false_positives_reported int DEFAULT 0,
    average_score numeric(5,3),
    UNIQUE(date, kebele)
);

-- View for potential duplicate HDSS records
CREATE OR REPLACE VIEW potential_duplicates AS
SELECT
    a.dss_id as dss_id_1,
    b.dss_id as dss_id_2,
    similarity(
        coalesce(a.first_name_latin, a.first_name, ''),
        coalesce(b.first_name_latin, b.first_name, '')
    ) as name_similarity,
    a.birth_year as birth_year_1,
    b.birth_year as birth_year_2,
    a.kebele,
    a.gott
FROM public.dss_individuals a
JOIN public.dss_individuals b ON
    a.dss_id < b.dss_id AND
    a.kebele = b.kebele AND
    similarity(
        coalesce(a.first_name_latin, a.first_name, '') || ' ' ||
        coalesce(a.father_name_latin, a.middle_name, ''),
        coalesce(b.first_name_latin, b.first_name, '') || ' ' ||
        coalesce(b.father_name_latin, b.middle_name, '')
    ) > 0.85 AND
    ABS(
        COALESCE(a.birth_year::int, 0) -
        COALESCE(b.birth_year::int, 0)
    ) <= 1;

-- ============================================================================
-- PART 9: ETHIOPIAN REGIONS REFERENCE TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.ethiopian_regions (
    region_code text PRIMARY KEY,
    region_name_english text NOT NULL,
    region_name_amharic text,
    population bigint,
    capital text
);

INSERT INTO public.ethiopian_regions (region_code, region_name_english, region_name_amharic) VALUES
    ('TI', 'Tigray', 'ትግራይ'),
    ('AF', 'Afar', 'ዓፋር'),
    ('AM', 'Amhara', 'አማራ'),
    ('OR', 'Oromia', 'ኦሮሚያ'),
    ('SO', 'Somali', 'ሱማሌ'),
    ('BG', 'Benishangul-Gumuz', 'ቤንሻንጉል ጉሙዝ'),
    ('SN', 'SNNPR', 'ደቡብ ብሔር ብሔረሰቦችና ሕዝቦች'),
    ('GM', 'Gambela', 'ጋምቤላ'),
    ('HR', 'Harari', 'ሐረሪ'),
    ('SD', 'Sidama', 'ሲዳማ'),
    ('SW', 'South West Ethiopia', 'ደቡብ ምዕራብ'),
    ('AA', 'Addis Ababa', 'አዲስ አበባ'),
    ('DD', 'Dire Dawa', 'ድሬዳዋ')
ON CONFLICT (region_code) DO NOTHING;

-- ============================================================================
-- PART 10: DATA MIGRATION HELPERS
-- ============================================================================

-- Function to migrate existing data to Ethiopian structure
CREATE OR REPLACE FUNCTION migrate_to_ethiopian_structure()
RETURNS void AS $$
BEGIN
    -- Map existing fields to Ethiopian equivalents
    UPDATE public.dss_individuals
    SET
        first_name_latin = COALESCE(first_name_latin, first_name),
        father_name_latin = COALESCE(father_name_latin, middle_name),
        kebele = COALESCE(kebele, village),
        gott = COALESCE(gott, subvillage)
    WHERE first_name_latin IS NULL OR kebele IS NULL;

    RAISE NOTICE 'Migration completed. Review and adjust as needed.';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- NOTES FOR DEPLOYMENT
-- ============================================================================

-- After running this migration:
-- 1. Run: SELECT migrate_to_ethiopian_structure();
-- 2. Update search function (0003_functions.sql) to use new Ethiopian fields
-- 3. Update API DTOs to include new fields
-- 4. Update Blazor UI to show Ethiopian administrative divisions
-- 5. Test thoroughly with sample Ethiopian HDSS data

-- To verify migration:
-- SELECT COUNT(*) as total,
--        COUNT(kebele) as with_kebele,
--        COUNT(first_name_latin) as with_latin_name
-- FROM public.dss_individuals;
