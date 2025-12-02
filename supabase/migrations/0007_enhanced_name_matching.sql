-- Enhanced Name Matching for Ethiopian HDSS
-- Month 2 Week 3-4: Abbreviation expansion, name variants, and phonetic matching

-- ================================================================
-- 1. Abbreviation Expansion Table
-- ================================================================
-- Common Ethiopian name abbreviations (especially Tigrinya/Amharic)

CREATE TABLE IF NOT EXISTS public.name_abbreviations (
    id SERIAL PRIMARY KEY,
    abbreviation TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    language TEXT, -- 'ti' (Tigrinya), 'am' (Amharic), 'both'
    usage_frequency INTEGER DEFAULT 1, -- For ranking common abbreviations
    CONSTRAINT abbrev_lang_check CHECK (language IN ('ti', 'am', 'both', NULL))
);

-- Common Ethiopian name abbreviations
INSERT INTO public.name_abbreviations (abbreviation, full_name, language, usage_frequency) VALUES
    -- Gebre- prefix (meaning "servant of")
    ('G', 'Gebre', 'both', 100),
    ('G/', 'Gebre', 'both', 100),
    ('Gb', 'Gebre', 'both', 80),
    ('Gb/', 'Gebre', 'both', 80),

    -- Tesfa- prefix (meaning "hope")
    ('T', 'Tesfa', 'both', 90),
    ('T/', 'Tesfa', 'both', 90),
    ('Ts', 'Tesfa', 'both', 70),
    ('Ts/', 'Tesfa', 'both', 70),

    -- Haile/Hail- prefix (meaning "power")
    ('H', 'Haile', 'both', 85),
    ('H/', 'Haile', 'both', 85),

    -- Kidane/Kidan- prefix (meaning "covenant")
    ('K', 'Kidane', 'both', 75),
    ('K/', 'Kidane', 'both', 75),
    ('Kd', 'Kidane', 'both', 60),

    -- Welde- prefix (meaning "son of")
    ('W', 'Welde', 'both', 70),
    ('W/', 'Welde', 'both', 70),
    ('Wld', 'Welde', 'both', 60),

    -- Abreha/Abraha- prefix
    ('A', 'Abraha', 'both', 65),
    ('A/', 'Abraha', 'both', 65),
    ('Abr', 'Abraha', 'both', 55),

    -- Tekle- prefix (meaning "plant")
    ('Tk', 'Tekle', 'both', 60),
    ('Tkl', 'Tekle', 'both', 55),

    -- Fikre- prefix (meaning "love")
    ('F', 'Fikre', 'both', 50),
    ('F/', 'Fikre', 'both', 50),
    ('Fk', 'Fikre', 'both', 45),

    -- Berhane- prefix (meaning "light")
    ('B', 'Berhane', 'both', 55),
    ('B/', 'Berhane', 'both', 55),
    ('Brh', 'Berhane', 'both', 50),

    -- Mekonnen- prefix
    ('M', 'Mekonnen', 'both', 50),
    ('M/', 'Mekonnen', 'both', 50),
    ('Mkn', 'Mekonnen', 'both', 45)
ON CONFLICT (abbreviation) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_abbrev_lookup ON public.name_abbreviations(abbreviation);

-- ================================================================
-- 2. Common Name Variants Table
-- ================================================================
-- Captures phonetic variants, spelling variations, and alternate forms

CREATE TABLE IF NOT EXISTS public.name_variants (
    id SERIAL PRIMARY KEY,
    canonical_name TEXT NOT NULL, -- Standard/most common spelling
    variant_name TEXT NOT NULL,
    variant_type TEXT, -- 'phonetic', 'spelling', 'transliteration', 'diminutive'
    language TEXT, -- 'ti', 'am', 'en', 'both'
    similarity_score NUMERIC(3,2) DEFAULT 0.95, -- How closely related (0.0-1.0)
    CONSTRAINT variant_type_check CHECK (variant_type IN ('phonetic', 'spelling', 'transliteration', 'diminutive', NULL)),
    CONSTRAINT variant_lang_check CHECK (language IN ('ti', 'am', 'en', 'both', NULL)),
    CONSTRAINT similarity_range CHECK (similarity_score >= 0.0 AND similarity_score <= 1.0)
);

-- Common Ethiopian name variants (Tigrinya/Amharic)
INSERT INTO public.name_variants (canonical_name, variant_name, variant_type, language, similarity_score) VALUES
    -- Gebre- variants
    ('Gebre', 'Gebere', 'spelling', 'both', 0.98),
    ('Gebre', 'Gebri', 'phonetic', 'ti', 0.95),
    ('Gebre', 'Gebereh', 'spelling', 'both', 0.95),
    ('Gebre', 'Gbre', 'spelling', 'both', 0.90),

    -- Gebrehiwot variants (common name)
    ('Gebrehiwot', 'Gebrehiwet', 'spelling', 'both', 0.98),
    ('Gebrehiwot', 'Gebrehiot', 'spelling', 'both', 0.95),
    ('Gebrehiwot', 'Gebrihiwot', 'phonetic', 'ti', 0.93),
    ('Gebrehiwot', 'G/Hiwot', 'abbreviation', 'both', 0.90),

    -- Tesfay/Tesfaye variants
    ('Tesfay', 'Tesfaye', 'spelling', 'both', 0.98),
    ('Tesfay', 'Tesfai', 'spelling', 'both', 0.97),
    ('Tesfay', 'Tesfy', 'spelling', 'both', 0.92),
    ('Tesfay', 'Tesfey', 'spelling', 'both', 0.95),

    -- Haile variants
    ('Haile', 'Hailé', 'spelling', 'both', 0.99),
    ('Haile', 'Hayle', 'spelling', 'both', 0.97),
    ('Haile', 'Hail', 'spelling', 'both', 0.93),
    ('Haile', 'Hile', 'spelling', 'both', 0.90),

    -- Tekle variants
    ('Tekle', 'Teklie', 'spelling', 'both', 0.97),
    ('Tekle', 'Tekele', 'spelling', 'both', 0.95),
    ('Tekle', 'Tkle', 'spelling', 'both', 0.90),

    -- Abraha variants
    ('Abraha', 'Abreha', 'spelling', 'both', 0.97),
    ('Abraha', 'Abriha', 'phonetic', 'ti', 0.93),
    ('Abraha', 'Abrahe', 'spelling', 'both', 0.95),

    -- Berhane variants
    ('Berhane', 'Brhane', 'spelling', 'both', 0.95),
    ('Berhane', 'Birhane', 'spelling', 'both', 0.93),
    ('Berhane', 'Berhan', 'spelling', 'both', 0.90),

    -- Kiros/Kiross variants
    ('Kiros', 'Kiross', 'spelling', 'both', 0.98),
    ('Kiros', 'Kirus', 'spelling', 'both', 0.95),
    ('Kiros', 'Kyros', 'spelling', 'both', 0.93),

    -- Hagos variants
    ('Hagos', 'Hagoss', 'spelling', 'both', 0.98),
    ('Hagos', 'Hागos', 'spelling', 'both', 0.95),
    ('Hagos', 'Hgos', 'spelling', 'both', 0.90),

    -- Weldu/Woldu variants
    ('Weldu', 'Woldu', 'phonetic', 'both', 0.96),
    ('Weldu', 'Welde', 'spelling', 'both', 0.93),
    ('Weldu', 'Wldu', 'spelling', 'both', 0.88),

    -- Gebru variants
    ('Gebru', 'Gebrue', 'spelling', 'both', 0.97),
    ('Gebru', 'Gebere', 'phonetic', 'both', 0.90),
    ('Gebru', 'Gbru', 'spelling', 'both', 0.88),

    -- Mekonnen variants
    ('Mekonnen', 'Mekonin', 'spelling', 'both', 0.95),
    ('Mekonnen', 'Mkonen', 'spelling', 'both', 0.92),
    ('Mekonnen', 'Mekonen', 'spelling', 'both', 0.97),

    -- Alem variants
    ('Alem', 'Alemu', 'spelling', 'both', 0.95),
    ('Alem', 'Alemayehu', 'diminutive', 'both', 0.85),
    ('Alem', 'Alim', 'phonetic', 'both', 0.90),

    -- Mulu variants
    ('Mulu', 'Mullu', 'spelling', 'both', 0.98),
    ('Mulu', 'Mulu Work', 'diminutive', 'both', 0.85),

    -- Female names
    ('Tirhas', 'Tirhass', 'spelling', 'both', 0.98),
    ('Tirhas', 'Tirhas', 'spelling', 'both', 0.95),

    ('Tsehay', 'Tsehaye', 'spelling', 'both', 0.97),
    ('Tsehay', 'Tsehai', 'spelling', 'both', 0.95),
    ('Tsehay', 'Tshay', 'spelling', 'both', 0.90),

    ('Letekiros', 'Letekrос', 'spelling', 'both', 0.97),
    ('Letekiros', 'Ltekiros', 'spelling', 'both', 0.93),

    ('Yordanos', 'Yordanoss', 'spelling', 'both', 0.98),
    ('Yordanos', 'Yohannes', 'phonetic', 'both', 0.85)
ON CONFLICT DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_canonical_name ON public.name_variants(canonical_name);
CREATE INDEX IF NOT EXISTS idx_variant_name ON public.name_variants(variant_name);

-- ================================================================
-- 3. Phonetic Matching Helper Function (Metaphone-like for Ethiopic)
-- ================================================================
-- Simplified phonetic encoding for Ethiopian names

CREATE OR REPLACE FUNCTION public.ethiopic_phonetic_code(name TEXT)
RETURNS TEXT
LANGUAGE SQL
IMMUTABLE
AS $$
    SELECT LOWER(
        -- Remove accents and normalize
        unaccent(name)
    )
    -- Phonetic simplifications for Ethiopian names
    -- Remove silent letters and normalize similar sounds
    |> REPLACE($$, 'gh', 'g')
    |> REPLACE($$, 'kh', 'k')
    |> REPLACE($$, 'ph', 'f')
    |> REPLACE($$, 'ts', 's')
    |> REPLACE($$, 'tz', 's')
    |> REPLACE($$, 'ay', 'e')
    |> REPLACE($$, 'ey', 'e')
    |> REPLACE($$, 'ie', 'i')
    |> REPLACE($$, 'ye', 'e')
    -- Double consonants to single
    |> REGEXP_REPLACE($$, '([a-z])\1+', '\1', 'g')
    -- Remove non-alphanumeric
    |> REGEXP_REPLACE($$, '[^a-z0-9]', '', 'g');
$$;

-- ================================================================
-- 4. Abbreviation Expansion Helper Function
-- ================================================================

CREATE OR REPLACE FUNCTION public.expand_abbreviations(name TEXT)
RETURNS TEXT
LANGUAGE SQL
STABLE
AS $$
    -- Expand common abbreviations in Ethiopian names
    -- Example: "G/Hiwot" → "Gebre Hiwot"
    WITH expanded AS (
        SELECT
            REGEXP_REPLACE(
                name,
                '(' || STRING_AGG(REGEXP_REPLACE(abbreviation, '([/.+*?[{}()|\^$])', '\\\1', 'g'), '|') || ')',
                full_name,
                'gi'
            ) AS expanded_name
        FROM public.name_abbreviations
        WHERE abbreviation ~ '^[A-Z]+/?$'  -- Match abbreviation patterns
        GROUP BY name
    )
    SELECT COALESCE(expanded_name, name)
    FROM expanded
    LIMIT 1;
$$;

-- ================================================================
-- 5. Name Variant Lookup Function
-- ================================================================

CREATE OR REPLACE FUNCTION public.get_name_variants(input_name TEXT)
RETURNS TABLE(variant TEXT, score NUMERIC)
LANGUAGE SQL
STABLE
AS $$
    -- Return all known variants of a name with similarity scores
    SELECT variant_name AS variant, similarity_score AS score
    FROM public.name_variants
    WHERE canonical_name = input_name

    UNION

    SELECT canonical_name AS variant, similarity_score AS score
    FROM public.name_variants
    WHERE variant_name = input_name

    UNION

    -- Also return the input name itself with perfect score
    SELECT input_name AS variant, 1.0 AS score;
$$;

-- ================================================================
-- 6. Enhanced Name Matching Score Function
-- ================================================================

CREATE OR REPLACE FUNCTION public.enhanced_name_similarity(
    search_name TEXT,
    candidate_name TEXT
)
RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    direct_sim DOUBLE PRECISION;
    phonetic_sim DOUBLE PRECISION;
    expanded_search TEXT;
    expanded_candidate TEXT;
    variant_score DOUBLE PRECISION := 0.0;
    max_score DOUBLE PRECISION;
BEGIN
    -- 1. Direct trigram similarity (base score)
    direct_sim := similarity(unaccent(search_name), unaccent(candidate_name));

    -- 2. Phonetic similarity
    phonetic_sim := similarity(
        ethiopic_phonetic_code(search_name),
        ethiopic_phonetic_code(candidate_name)
    );

    -- 3. Abbreviation expansion similarity
    expanded_search := expand_abbreviations(search_name);
    expanded_candidate := expand_abbreviations(candidate_name);

    IF expanded_search != search_name OR expanded_candidate != candidate_name THEN
        -- One or both names had abbreviations, check expanded similarity
        direct_sim := GREATEST(
            direct_sim,
            similarity(unaccent(expanded_search), unaccent(expanded_candidate))
        );
    END IF;

    -- 4. Check known variants table
    IF EXISTS (
        SELECT 1 FROM public.name_variants
        WHERE (canonical_name = search_name AND variant_name = candidate_name)
           OR (canonical_name = candidate_name AND variant_name = search_name)
    ) THEN
        SELECT COALESCE(MAX(similarity_score), 0.0) INTO variant_score
        FROM public.name_variants
        WHERE (canonical_name = search_name AND variant_name = candidate_name)
           OR (canonical_name = candidate_name AND variant_name = search_name);
    END IF;

    -- 5. Take the maximum score from all methods
    max_score := GREATEST(
        direct_sim,
        phonetic_sim * 0.95,  -- Phonetic slightly discounted
        variant_score
    );

    RETURN max_score;
END;
$$;

-- ================================================================
-- 7. Test Cases and Verification
-- ================================================================

-- Test abbreviation expansion
DO $$
BEGIN
    RAISE NOTICE 'Testing abbreviation expansion:';
    RAISE NOTICE '  G/Hiwot → %', expand_abbreviations('G/Hiwot');
    RAISE NOTICE '  T/Mariam → %', expand_abbreviations('T/Mariam');
    RAISE NOTICE '  Gb/Selassie → %', expand_abbreviations('Gb/Selassie');
END $$;

-- Test phonetic encoding
DO $$
BEGIN
    RAISE NOTICE 'Testing phonetic encoding:';
    RAISE NOTICE '  Gebrehiwot → %', ethiopic_phonetic_code('Gebrehiwot');
    RAISE NOTICE '  Gebrehiwet → %', ethiopic_phonetic_code('Gebrehiwet');
    RAISE NOTICE '  Gebrehiot → %', ethiopic_phonetic_code('Gebrehiot');
    RAISE NOTICE '  Tesfay → %', ethiopic_phonetic_code('Tesfay');
    RAISE NOTICE '  Tesfaye → %', ethiopic_phonetic_code('Tesfaye');
END $$;

-- Test enhanced name similarity
DO $$
DECLARE
    score1 DOUBLE PRECISION;
    score2 DOUBLE PRECISION;
    score3 DOUBLE PRECISION;
BEGIN
    RAISE NOTICE 'Testing enhanced name similarity:';

    score1 := enhanced_name_similarity('Gebrehiwot', 'Gebrehiwot');
    RAISE NOTICE '  Gebrehiwot vs Gebrehiwot: % (expect ~1.0)', score1;

    score2 := enhanced_name_similarity('Gebrehiwot', 'Gebrehiwet');
    RAISE NOTICE '  Gebrehiwot vs Gebrehiwet: % (expect ~0.95+)', score2;

    score3 := enhanced_name_similarity('G/Hiwot', 'Gebrehiwot');
    RAISE NOTICE '  G/Hiwot vs Gebrehiwot: % (expect ~0.90+)', score3;
END $$;

-- Summary statistics
SELECT
    'Abbreviations loaded' AS metric,
    COUNT(*) AS count
FROM public.name_abbreviations

UNION ALL

SELECT
    'Name variants loaded' AS metric,
    COUNT(*) AS count
FROM public.name_variants;

COMMENT ON TABLE public.name_abbreviations IS 'Ethiopian name abbreviation expansion dictionary (G/ = Gebre-, T/ = Tesfa-, etc.)';
COMMENT ON TABLE public.name_variants IS 'Common Ethiopian name variants for improved phonetic and spelling matching';
COMMENT ON FUNCTION public.ethiopic_phonetic_code(TEXT) IS 'Simplified phonetic encoding for Ethiopian names (Metaphone-like)';
COMMENT ON FUNCTION public.expand_abbreviations(TEXT) IS 'Expands common Ethiopian name abbreviations';
COMMENT ON FUNCTION public.enhanced_name_similarity(TEXT, TEXT) IS 'Enhanced name matching with abbreviations, phonetics, and variants';
