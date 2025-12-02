-- Integrate Enhanced Name Matching into search_candidates Function
-- Month 2 Week 3-4: Use abbreviation expansion, variants, and phonetic matching

-- Drop the old function
DROP FUNCTION IF EXISTS public.search_candidates(
    _first_name TEXT, _middle_name TEXT, _last_name TEXT,
    _tl_first_name TEXT, _tl_middle_name TEXT, _tl_last_name TEXT,
    _gender TEXT, _bday TEXT, _bmonth TEXT, _byear TEXT,
    _village TEXT, _subvillage TEXT,
    _use_first_name BOOLEAN, _use_middle_name BOOLEAN, _use_last_name BOOLEAN,
    _use_tl_first_name BOOLEAN, _use_tl_middle_name BOOLEAN, _use_tl_last_name BOOLEAN,
    _use_gender BOOLEAN, _use_bday BOOLEAN, _use_bmonth BOOLEAN, _use_byear BOOLEAN,
    _use_village BOOLEAN, _use_subvillage BOOLEAN
);

-- Recreate with enhanced matching
CREATE OR REPLACE FUNCTION public.search_candidates(
    _first_name TEXT DEFAULT NULL,
    _middle_name TEXT DEFAULT NULL,
    _last_name TEXT DEFAULT NULL,
    _tl_first_name TEXT DEFAULT NULL,
    _tl_middle_name TEXT DEFAULT NULL,
    _tl_last_name TEXT DEFAULT NULL,
    _gender TEXT DEFAULT NULL,
    _bday TEXT DEFAULT NULL,
    _bmonth TEXT DEFAULT NULL,
    _byear TEXT DEFAULT NULL,
    _village TEXT DEFAULT NULL,
    _subvillage TEXT DEFAULT NULL,
    _use_first_name BOOLEAN DEFAULT FALSE,
    _use_middle_name BOOLEAN DEFAULT FALSE,
    _use_last_name BOOLEAN DEFAULT FALSE,
    _use_tl_first_name BOOLEAN DEFAULT FALSE,
    _use_tl_middle_name BOOLEAN DEFAULT FALSE,
    _use_tl_last_name BOOLEAN DEFAULT FALSE,
    _use_gender BOOLEAN DEFAULT FALSE,
    _use_bday BOOLEAN DEFAULT FALSE,
    _use_bmonth BOOLEAN DEFAULT FALSE,
    _use_byear BOOLEAN DEFAULT FALSE,
    _use_village BOOLEAN DEFAULT FALSE,
    _use_subvillage BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
    dss_id TEXT,
    birth_year TEXT,
    score DOUBLE PRECISION,
    rank_no_gap INT,
    rank_gap INT,
    row_number INT,
    name_score DOUBLE PRECISION,
    location TEXT,
    first_name TEXT,
    middle_name TEXT,
    last_name TEXT,
    gender TEXT
)
LANGUAGE SQL
STABLE
AS $$
WITH q AS (
    SELECT
        di.dss_id,
        di.birth_year,
        di.birth_day,
        di.birth_month,
        di.first_name,
        di.middle_name,
        di.last_name,
        di.gender,
        di.location,
        di.village,
        di.subvillage,
        -- Standard concatenated names
        unaccent(COALESCE(di.first_name,'') || ' ' || COALESCE(di.middle_name,'') || ' ' || COALESCE(di.last_name,'')) AS nm,
        unaccent(COALESCE(di.tl_first_name,'') || ' ' || COALESCE(di.tl_middle_name,'') || ' ' || COALESCE(di.tl_last_name,'')) AS tlnm,
        -- ENHANCED: Expanded names (abbreviations resolved)
        unaccent(
            COALESCE(expand_abbreviations(di.first_name),'') || ' ' ||
            COALESCE(expand_abbreviations(di.middle_name),'') || ' ' ||
            COALESCE(expand_abbreviations(di.last_name),'')
        ) AS nm_expanded,
        -- ENHANCED: Phonetic codes for names
        ethiopic_phonetic_code(COALESCE(di.first_name,'')) AS fn_phonetic,
        ethiopic_phonetic_code(COALESCE(di.middle_name,'')) AS mn_phonetic,
        ethiopic_phonetic_code(COALESCE(di.last_name,'')) AS ln_phonetic
    FROM public.dss_individuals di
),
inputs AS (
    SELECT
        unaccent(TRIM(COALESCE(_first_name,'') || ' ' || COALESCE(_middle_name,'') || ' ' || COALESCE(_last_name,''))) AS nm,
        unaccent(TRIM(COALESCE(_tl_first_name,'') || ' ' || COALESCE(_tl_middle_name,'') || ' ' || COALESCE(_tl_last_name,''))) AS tlnm,
        -- ENHANCED: Expanded search names
        unaccent(TRIM(
            COALESCE(expand_abbreviations(_first_name),'') || ' ' ||
            COALESCE(expand_abbreviations(_middle_name),'') || ' ' ||
            COALESCE(expand_abbreviations(_last_name),'')
        )) AS nm_expanded,
        -- ENHANCED: Phonetic codes for search terms
        ethiopic_phonetic_code(COALESCE(_first_name,'')) AS fn_phonetic,
        ethiopic_phonetic_code(COALESCE(_middle_name,'')) AS mn_phonetic,
        ethiopic_phonetic_code(COALESCE(_last_name,'')) AS ln_phonetic
),
scored AS (
    SELECT
        q.*,
        -- ENHANCED: Individual name similarities (using enhanced_name_similarity)
        (CASE WHEN _use_first_name AND _first_name IS NOT NULL THEN
            enhanced_name_similarity(_first_name, q.first_name)
         ELSE 0 END) AS sim_fn,

        (CASE WHEN _use_middle_name AND _middle_name IS NOT NULL THEN
            enhanced_name_similarity(_middle_name, q.middle_name)
         ELSE 0 END) AS sim_mn,

        (CASE WHEN _use_last_name AND _last_name IS NOT NULL THEN
            enhanced_name_similarity(_last_name, q.last_name)
         ELSE 0 END) AS sim_ln,

        -- Transliterated names (standard trigram)
        (CASE WHEN _use_tl_first_name THEN
            similarity(unaccent(COALESCE(_tl_first_name,'')), unaccent(COALESCE(SPLIT_PART(q.tlnm,' ',1),'')))
         ELSE 0 END) AS sim_tlfn,

        (CASE WHEN _use_tl_middle_name THEN
            similarity(unaccent(COALESCE(_tl_middle_name,'')), unaccent(COALESCE(SPLIT_PART(q.tlnm,' ',2),'')))
         ELSE 0 END) AS sim_tlmn,

        (CASE WHEN _use_tl_last_name THEN
            similarity(unaccent(COALESCE(_tl_last_name,'')), unaccent(COALESCE(SPLIT_PART(q.tlnm,' ',3),'')))
         ELSE 0 END) AS sim_tlln,

        -- Gender matching
        (CASE WHEN _use_gender AND _gender IS NOT NULL AND q.gender IS NOT NULL AND LOWER(_gender)=LOWER(q.gender)
         THEN 1.0 ELSE 0 END) AS sim_gender,

        -- Birth date matching
        (CASE WHEN _use_bday AND _bday IS NOT NULL AND q.birth_day IS NOT NULL AND _bday = q.birth_day
         THEN 1.0 ELSE 0 END) AS sim_bday,

        (CASE WHEN _use_bmonth AND _bmonth IS NOT NULL AND q.birth_month IS NOT NULL AND _bmonth = q.birth_month
         THEN 1.0 ELSE 0 END) AS sim_bmonth,

        (CASE WHEN _use_byear AND _byear IS NOT NULL AND q.birth_year IS NOT NULL THEN
            GREATEST(0, 1 - (ABS(COALESCE(_byear,'0')::INT - COALESCE(q.birth_year,'0')::INT)::NUMERIC / 10))::DOUBLE PRECISION
         ELSE 0 END) AS sim_byear,

        -- ENHANCED: Location matching with Tabia/Kushet codes
        (CASE WHEN _use_village AND _village IS NOT NULL THEN
            CASE
                -- Exact code match (KA-AGBE = KA-AGBE)
                WHEN q.village = _village THEN 1.0
                -- Fuzzy name match for legacy data
                ELSE similarity(unaccent(_village), unaccent(COALESCE(q.village,'')))
            END
         ELSE 0 END) AS sim_village,

        (CASE WHEN _use_subvillage AND _subvillage IS NOT NULL THEN
            CASE
                -- Exact code match (KA-AGBE-01 = KA-AGBE-01)
                WHEN q.subvillage = _subvillage THEN 1.0
                -- Fuzzy name match for legacy data
                ELSE similarity(unaccent(_subvillage), unaccent(COALESCE(q.subvillage,'')))
            END
         ELSE 0 END) AS sim_subvillage,

        -- ENHANCED: Overall name score (using expanded + phonetic)
        GREATEST(
            similarity((SELECT nm FROM inputs), q.nm),
            similarity((SELECT nm_expanded FROM inputs), q.nm_expanded),
            -- Phonetic full name similarity
            similarity(
                (SELECT fn_phonetic || mn_phonetic || ln_phonetic FROM inputs),
                q.fn_phonetic || q.mn_phonetic || q.ln_phonetic
            ) * 0.95  -- Phonetic slightly discounted
        ) AS name_score
    FROM q
)
SELECT
    dss_id,
    birth_year,
    -- ENHANCED: Weighted score (patronymic emphasis)
    -- Ethiopian names: Given (40%) + Father's (30%) + Grandfather's (15%)
    -- This emphasizes the patronymic structure
    (
        0.40 * sim_fn +      -- Given name (most important for individual identity)
        0.30 * sim_mn +      -- Father's name (patronymic, second most important)
        0.15 * sim_ln +      -- Grandfather's name (family lineage)
        0.02 * sim_tlfn +    -- Transliterated names (minor boost)
        0.01 * sim_tlmn +
        0.01 * sim_tlln +
        0.05 * sim_gender +  -- Gender confirmation
        0.02 * sim_bday +    -- Birth date components
        0.02 * sim_bmonth +
        0.03 * sim_byear +
        0.03 * sim_village + -- Location (Tabia)
        0.01 * sim_subvillage -- Sub-location (Kushet)
    ) AS score,

    -- Rankings
    DENSE_RANK() OVER (ORDER BY (
        0.40 * sim_fn + 0.30 * sim_mn + 0.15 * sim_ln +
        0.02 * sim_tlfn + 0.01 * sim_tlmn + 0.01 * sim_tlln +
        0.05 * sim_gender + 0.02 * sim_bday + 0.02 * sim_bmonth + 0.03 * sim_byear +
        0.03 * sim_village + 0.01 * sim_subvillage
    ) DESC) AS rank_no_gap,

    RANK() OVER (ORDER BY (
        0.40 * sim_fn + 0.30 * sim_mn + 0.15 * sim_ln +
        0.02 * sim_tlfn + 0.01 * sim_tlmn + 0.01 * sim_tlln +
        0.05 * sim_gender + 0.02 * sim_bday + 0.02 * sim_bmonth + 0.03 * sim_byear +
        0.03 * sim_village + 0.01 * sim_subvillage
    ) DESC) AS rank_gap,

    ROW_NUMBER() OVER (ORDER BY (
        0.40 * sim_fn + 0.30 * sim_mn + 0.15 * sim_ln +
        0.02 * sim_tlfn + 0.01 * sim_tlmn + 0.01 * sim_tlln +
        0.05 * sim_gender + 0.02 * sim_bday + 0.02 * sim_bmonth + 0.03 * sim_byear +
        0.03 * sim_village + 0.01 * sim_subvillage
    ) DESC) AS row_number,

    name_score,
    location,
    first_name,
    middle_name,
    last_name,
    gender

FROM scored
WHERE (
    -- ENHANCED: Return candidates with reasonable overall score OR high name match
    (0.40 * sim_fn + 0.30 * sim_mn + 0.15 * sim_ln +
     0.02 * sim_tlfn + 0.01 * sim_tlmn + 0.01 * sim_tlln +
     0.05 * sim_gender + 0.02 * sim_bday + 0.02 * sim_bmonth + 0.03 * sim_byear +
     0.03 * sim_village + 0.01 * sim_subvillage) >= 0.25
    OR name_score >= 0.40  -- High name similarity alone
)
ORDER BY score DESC, name_score DESC
LIMIT 100;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.search_candidates IS 'Enhanced Ethiopian HDSS search with abbreviation expansion, name variants, phonetic matching, and patronymic-weighted scoring';

-- Test the enhanced search
DO $$
DECLARE
    result_count INT;
BEGIN
    RAISE NOTICE 'Testing enhanced search_candidates function...';

    -- Test 1: Search with abbreviation (should expand and match)
    SELECT COUNT(*) INTO result_count
    FROM search_candidates(
        _first_name => 'T/Mariam',
        _use_first_name => TRUE
    );
    RAISE NOTICE 'Test 1 (Abbreviation): Found % candidates for "T/Mariam"', result_count;

    -- Test 2: Search with spelling variant
    SELECT COUNT(*) INTO result_count
    FROM search_candidates(
        _first_name => 'Tesfaye',
        _middle_name => 'Gebrehiwet',
        _use_first_name => TRUE,
        _use_middle_name => TRUE
    );
    RAISE NOTICE 'Test 2 (Variants): Found % candidates for "Tesfaye Gebrehiwet"', result_count;

    RAISE NOTICE 'Enhanced search function deployed successfully!';
END $$;
