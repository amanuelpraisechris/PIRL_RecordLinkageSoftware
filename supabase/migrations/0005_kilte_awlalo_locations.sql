-- Kilte Awlalo HDSS Location Data
-- ==================================
-- Region: Tigray
-- Zone: Eastern Zone
-- Woreda: Kilte Awlalo
-- Population: ~67,000 individuals under surveillance
-- Established: 2009 (Mekelle University)
--
-- Administrative Structure:
-- - 10 Tabias (sub-districts)
-- - 33 Kushets (village clusters)
-- - Multiple Gotts (sub-villages) per Kushet

-- Create location reference tables if they don't exist
CREATE TABLE IF NOT EXISTS public.tabias (
  id SERIAL PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  name_tigrinya TEXT NOT NULL,
  name_amharic TEXT,
  name_english TEXT NOT NULL,
  woreda TEXT NOT NULL DEFAULT 'Kilte Awlalo',
  zone TEXT NOT NULL DEFAULT 'Eastern Zone',
  region TEXT NOT NULL DEFAULT 'Tigray',
  population_estimate INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.kushets (
  id SERIAL PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  name_tigrinya TEXT NOT NULL,
  name_amharic TEXT,
  name_english TEXT NOT NULL,
  tabia_code TEXT NOT NULL REFERENCES public.tabias(code),
  population_estimate INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.health_facilities_kilte_awlalo (
  id SERIAL PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  name_tigrinya TEXT NOT NULL,
  name_amharic TEXT,
  name_english TEXT NOT NULL,
  facility_type TEXT NOT NULL, -- General Hospital, Health Center, Health Post
  tabia_code TEXT REFERENCES public.tabias(code),
  catchment_population INTEGER,
  services TEXT[], -- ART, PMTCT, TB, ANC, etc.
  has_electricity BOOLEAN DEFAULT TRUE,
  has_internet BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert 10 Tabias of Kilte Awlalo Woreda
INSERT INTO public.tabias (code, name_tigrinya, name_amharic, name_english, population_estimate) VALUES
  ('KA-AGBE', 'ኣግበ', 'አግቤ', 'Agbe', 7200),
  ('KA-WUKRO', 'ውቕሮ', 'ውቕሮ', 'Wukro Town', 12500),
  ('KA-CHELE', 'ጨሌ', 'ቼሌ', 'Chele', 6800),
  ('KA-DERA', 'ዴራ', 'ዴራ', 'Dera', 5900),
  ('KA-ENDAHWUKRO', 'እንዳሁውቕሮ', 'እንዳሁውቕሮ', 'Endahwukro', 6400),
  ('KA-GENFEL', 'ገንፈል', 'ገንፈል', 'Genfel', 5500),
  ('KA-HAREZA', 'ሓረዛ', 'ሓረዛ', 'Hareza', 7100),
  ('KA-SHIBDIH', 'ሽብዲህ', 'ሽብዲህ', 'Shibdih', 6200),
  ('KA-TSAEDA', 'ጻዕዳ', 'ጻዕዳ', 'Tsaeda Emba', 5400),
  ('KA-ZABA', 'ዛባ', 'ዛባ', 'Zaba Guna', 4000);

-- Insert 33 Kushets mapped to their respective Tabias
-- Agbe Tabia (4 Kushets)
INSERT INTO public.kushets (code, name_tigrinya, name_amharic, name_english, tabia_code, population_estimate) VALUES
  ('KA-AGBE-01', 'ኣግበ', 'አግቤ', 'Agbe', 'KA-AGBE', 2400),
  ('KA-AGBE-02', 'ገንፈል', 'ገንፈል', 'Genfel', 'KA-AGBE', 2100),
  ('KA-AGBE-03', 'ማይ ጨው', 'ማይ ጨው', 'May Chew', 'KA-AGBE', 1500),
  ('KA-AGBE-04', 'አዲ ኩዋላ', 'አዲ ኩዋላ', 'Adi Kuwala', 'KA-AGBE', 1200);

-- Wukro Town Tabia (5 Kushets/Kebeles - urban)
INSERT INTO public.kushets (code, name_tigrinya, name_amharic, name_english, tabia_code, population_estimate) VALUES
  ('KA-WUKRO-01', 'ቀበሌ 01', 'ቀበሌ 01', 'Kebele 01', 'KA-WUKRO', 2800),
  ('KA-WUKRO-02', 'ቀበሌ 02', 'ቀበሌ 02', 'Kebele 02', 'KA-WUKRO', 2600),
  ('KA-WUKRO-03', 'ቀበሌ 03', 'ቀበሌ 03', 'Kebele 03', 'KA-WUKRO', 2400),
  ('KA-WUKRO-04', 'ቀበሌ 04', 'ቀበሌ 04', 'Kebele 04', 'KA-WUKRO', 2300),
  ('KA-WUKRO-05', 'ቀበሌ 05', 'ቀበሌ 05', 'Kebele 05', 'KA-WUKRO', 2400);

-- Chele Tabia (3 Kushets)
INSERT INTO public.kushets (code, name_tigrinya, name_amharic, name_english, tabia_code, population_estimate) VALUES
  ('KA-CHELE-01', 'ጨሌ', 'ቼሌ', 'Chele', 'KA-CHELE', 2700),
  ('KA-CHELE-02', 'ማይ ሃዝና', 'ማይ ሃዝና', 'May Hazna', 'KA-CHELE', 2200),
  ('KA-CHELE-03', 'ዓዲ ጉናድ', 'ዓዲ ጉናድ', 'Adi Gunad', 'KA-CHELE', 1900);

-- Dera Tabia (3 Kushets)
INSERT INTO public.kushets (code, name_tigrinya, name_amharic, name_english, tabia_code, population_estimate) VALUES
  ('KA-DERA-01', 'ዴራ', 'ዴራ', 'Dera', 'KA-DERA', 2400),
  ('KA-DERA-02', 'ቅዳነ ምሕረት', 'ቅዳነ ምሕረት', 'Kidane Mihret', 'KA-DERA', 2000),
  ('KA-DERA-03', 'ማይ ውቕሮ', 'ማይ ውቕሮ', 'May Wukro', 'KA-DERA', 1500);

-- Endahwukro Tabia (3 Kushets)
INSERT INTO public.kushets (code, name_tigrinya, name_amharic, name_english, tabia_code, population_estimate) VALUES
  ('KA-ENDA-01', 'እንዳሁውቕሮ', 'እንዳሁውቕሮ', 'Endahwukro', 'KA-ENDAHWUKRO', 2600),
  ('KA-ENDA-02', 'ብራህ', 'ብራህ', 'Brah', 'KA-ENDAHWUKRO', 2100),
  ('KA-ENDA-03', 'ዓሽም', 'ዓሽም', 'Ashim', 'KA-ENDAHWUKRO', 1700);

-- Genfel Tabia (3 Kushets)
INSERT INTO public.kushets (code, name_tigrinya, name_amharic, name_english, tabia_code, population_estimate) VALUES
  ('KA-GENFEL-01', 'ገንፈል', 'ገንፈል', 'Genfel', 'KA-GENFEL', 2200),
  ('KA-GENFEL-02', 'ሓውዜን', 'ሓውዜን', 'Hawzen', 'KA-GENFEL', 1800),
  ('KA-GENFEL-03', 'ሰልዕ', 'ሰልዕ', 'Sele', 'KA-GENFEL', 1500);

-- Hareza Tabia (4 Kushets)
INSERT INTO public.kushets (code, name_tigrinya, name_amharic, name_english, tabia_code, population_estimate) VALUES
  ('KA-HAREZA-01', 'ሓረዛ', 'ሓረዛ', 'Hareza', 'KA-HAREZA', 2500),
  ('KA-HAREZA-02', 'ዓዲ ዳኤሮ', 'ዓዲ ዳኤሮ', 'Adi Daero', 'KA-HAREZA', 2000),
  ('KA-HAREZA-03', 'ማይ ሚቲ', 'ማይ ሚቲ', 'May Miti', 'KA-HAREZA', 1600),
  ('KA-HAREZA-04', 'ዓዲ ግራት', 'ዓዲ ግራት', 'Adi Grat', 'KA-HAREZA', 1000);

-- Shibdih Tabia (3 Kushets)
INSERT INTO public.kushets (code, name_tigrinya, name_amharic, name_english, tabia_code, population_estimate) VALUES
  ('KA-SHIBDIH-01', 'ሽብዲህ', 'ሽብዲህ', 'Shibdih', 'KA-SHIBDIH', 2500),
  ('KA-SHIBDIH-02', 'ሕርሃር', 'ሕርሃር', 'Hirhar', 'KA-SHIBDIH', 2000),
  ('KA-SHIBDIH-03', 'ዓዲ መሓሪ', 'ዓዲ መሓሪ', 'Adi Mehari', 'KA-SHIBDIH', 1700);

-- Tsaeda Tabia (3 Kushets)
INSERT INTO public.kushets (code, name_tigrinya, name_amharic, name_english, tabia_code, population_estimate) VALUES
  ('KA-TSAEDA-01', 'ጻዕዳ እምባ', 'ጻዕዳ እምባ', 'Tsaeda Emba', 'KA-TSAEDA', 2300),
  ('KA-TSAEDA-02', 'ማይ ስኣን', 'ማይ ስኣን', 'May Sean', 'KA-TSAEDA', 1700),
  ('KA-TSAEDA-03', 'ዓዲ አብዬ', 'ዓዲ አብዬ', 'Adi Abye', 'KA-TSAEDA', 1400);

-- Zaba Tabia (2 Kushets)
INSERT INTO public.kushets (code, name_tigrinya, name_amharic, name_english, tabia_code, population_estimate) VALUES
  ('KA-ZABA-01', 'ዛባ ጉና', 'ዛባ ጉና', 'Zaba Guna', 'KA-ZABA', 2400),
  ('KA-ZABA-02', 'ዓዲ ሃገር', 'ዓዲ ሃገር', 'Adi Hager', 'KA-ZABA', 1600);

-- Insert Health Facilities in Kilte Awlalo catchment area
INSERT INTO public.health_facilities_kilte_awlalo (code, name_tigrinya, name_amharic, name_english, facility_type, tabia_code, catchment_population, services, has_electricity, has_internet) VALUES
  -- Wukro General Hospital (main referral)
  ('WGH-001', 'ሓፈሻዊ ሆስፒታል ውቕሮ', 'የውቕሮ ሓፈሻዊ ሆስፒታል', 'Wukro General Hospital', 'General Hospital', 'KA-WUKRO', 67000,
   ARRAY['ART', 'PMTCT', 'TB-DOTS', 'ANC', 'Delivery', 'Emergency', 'Surgery', 'Laboratory', 'Pharmacy'], TRUE, TRUE),

  -- Health Centers (5)
  ('HC-AGBE', 'ማእከል ጥዕና ኣግበ', 'የኣግበ ጤና ማዕከል', 'Agbe Health Center', 'Health Center', 'KA-AGBE', 7200,
   ARRAY['ART', 'PMTCT', 'TB-DOTS', 'ANC', 'Delivery', 'EPI', 'OPD'], TRUE, FALSE),

  ('HC-WUKRO', 'ማእከል ጥዕና ውቕሮ', 'የውቕሮ ጤና ማዕከል', 'Wukro Town Health Center', 'Health Center', 'KA-WUKRO', 12500,
   ARRAY['ART', 'PMTCT', 'TB-DOTS', 'ANC', 'Delivery', 'EPI', 'OPD', 'Laboratory'], TRUE, TRUE),

  ('HC-CHELE', 'ማእከል ጥዕና ጨሌ', 'የቼሌ ጤና ማዕከል', 'Chele Health Center', 'Health Center', 'KA-CHELE', 6800,
   ARRAY['PMTCT', 'TB-DOTS', 'ANC', 'Delivery', 'EPI', 'OPD'], TRUE, FALSE),

  ('HC-HAREZA', 'ማእከል ጥዕና ሓረዛ', 'የሓረዛ ጤና ማዕከል', 'Hareza Health Center', 'Health Center', 'KA-HAREZA', 7100,
   ARRAY['PMTCT', 'TB-DOTS', 'ANC', 'Delivery', 'EPI', 'OPD'], TRUE, FALSE),

  ('HC-ENDRA', 'ማእከል ጥዕና እንዳሁውቕሮ', 'የእንዳሁውቕሮ ጤና ማዕከል', 'Endahwukro Health Center', 'Health Center', 'KA-ENDAHWUKRO', 6400,
   ARRAY['PMTCT', 'TB-DOTS', 'ANC', 'Delivery', 'EPI', 'OPD'], FALSE, FALSE),

  -- Health Posts (10 - one per Tabia)
  ('HP-AGBE', 'ጣብያ ጥዕና ኣግበ', 'የኣግበ ጤና ጣቢያ', 'Agbe Health Post', 'Health Post', 'KA-AGBE', 7200,
   ARRAY['EPI', 'FP', 'ANC', 'Community Health'], FALSE, FALSE),

  ('HP-WUKRO', 'ጣብያ ጥዕና ውቕሮ', 'የውቕሮ ጤና ጣቢያ', 'Wukro Health Post', 'Health Post', 'KA-WUKRO', 12500,
   ARRAY['EPI', 'FP', 'ANC', 'Community Health'], TRUE, FALSE),

  ('HP-CHELE', 'ጣብያ ጥዕና ጨሌ', 'የቼሌ ጤና ጣቢያ', 'Chele Health Post', 'Health Post', 'KA-CHELE', 6800,
   ARRAY['EPI', 'FP', 'ANC', 'Community Health'], FALSE, FALSE),

  ('HP-DERA', 'ጣብያ ጥዕና ዴራ', 'የዴራ ጤና ጣቢያ', 'Dera Health Post', 'Health Post', 'KA-DERA', 5900,
   ARRAY['EPI', 'FP', 'ANC', 'Community Health'], FALSE, FALSE),

  ('HP-ENDRA', 'ጣብያ ጥዕና እንዳሁውቕሮ', 'የእንዳሁውቕሮ ጤና ጣቢያ', 'Endahwukro Health Post', 'Health Post', 'KA-ENDAHWUKRO', 6400,
   ARRAY['EPI', 'FP', 'ANC', 'Community Health'], FALSE, FALSE),

  ('HP-GENFEL', 'ጣብያ ጥዕና ገንፈል', 'የገንፈል ጤና ጣቢያ', 'Genfel Health Post', 'Health Post', 'KA-GENFEL', 5500,
   ARRAY['EPI', 'FP', 'ANC', 'Community Health'], FALSE, FALSE),

  ('HP-HAREZA', 'ጣብያ ጥዕና ሓረዛ', 'የሓረዛ ጤና ጣቢያ', 'Hareza Health Post', 'Health Post', 'KA-HAREZA', 7100,
   ARRAY['EPI', 'FP', 'ANC', 'Community Health'], FALSE, FALSE),

  ('HP-SHIBDIH', 'ጣብያ ጥዕና ሽብዲህ', 'የሽብዲህ ጤና ጣቢያ', 'Shibdih Health Post', 'Health Post', 'KA-SHIBDIH', 6200,
   ARRAY['EPI', 'FP', 'ANC', 'Community Health'], FALSE, FALSE),

  ('HP-TSAEDA', 'ጣብያ ጥዕና ጻዕዳ', 'የጻዕዳ ጤና ጣቢያ', 'Tsaeda Health Post', 'Health Post', 'KA-TSAEDA', 5400,
   ARRAY['EPI', 'FP', 'ANC', 'Community Health'], FALSE, FALSE),

  ('HP-ZABA', 'ጣብያ ጥዕና ዛባ', 'የዛባ ጤና ጣቢያ', 'Zaba Health Post', 'Health Post', 'KA-ZABA', 4000,
   ARRAY['EPI', 'FP', 'ANC', 'Community Health'], FALSE, FALSE);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_kushets_tabia ON public.kushets(tabia_code);
CREATE INDEX IF NOT EXISTS idx_facilities_tabia ON public.health_facilities_kilte_awlalo(tabia_code);
CREATE INDEX IF NOT EXISTS idx_facilities_type ON public.health_facilities_kilte_awlalo(facility_type);

-- Create view for easy location lookup
CREATE OR REPLACE VIEW public.kilte_awlalo_locations AS
SELECT
  t.code AS tabia_code,
  t.name_tigrinya AS tabia_name_tigrinya,
  t.name_english AS tabia_name_english,
  k.code AS kushet_code,
  k.name_tigrinya AS kushet_name_tigrinya,
  k.name_english AS kushet_name_english,
  t.population_estimate AS tabia_population,
  k.population_estimate AS kushet_population
FROM public.tabias t
LEFT JOIN public.kushets k ON k.tabia_code = t.code
WHERE t.woreda = 'Kilte Awlalo'
ORDER BY t.name_english, k.name_english;

-- Summary statistics
DO $$
DECLARE
  tabia_count INTEGER;
  kushet_count INTEGER;
  facility_count INTEGER;
  total_pop INTEGER;
BEGIN
  SELECT COUNT(*) INTO tabia_count FROM public.tabias WHERE woreda = 'Kilte Awlalo';
  SELECT COUNT(*) INTO kushet_count FROM public.kushets;
  SELECT COUNT(*) INTO facility_count FROM public.health_facilities_kilte_awlalo;
  SELECT SUM(population_estimate) INTO total_pop FROM public.tabias WHERE woreda = 'Kilte Awlalo';

  RAISE NOTICE '===================================';
  RAISE NOTICE 'Kilte Awlalo HDSS Location Data';
  RAISE NOTICE '===================================';
  RAISE NOTICE 'Tabias: %', tabia_count;
  RAISE NOTICE 'Kushets: %', kushet_count;
  RAISE NOTICE 'Health Facilities: %', facility_count;
  RAISE NOTICE '  - General Hospitals: %', (SELECT COUNT(*) FROM public.health_facilities_kilte_awlalo WHERE facility_type = 'General Hospital');
  RAISE NOTICE '  - Health Centers: %', (SELECT COUNT(*) FROM public.health_facilities_kilte_awlalo WHERE facility_type = 'Health Center');
  RAISE NOTICE '  - Health Posts: %', (SELECT COUNT(*) FROM public.health_facilities_kilte_awlalo WHERE facility_type = 'Health Post');
  RAISE NOTICE 'Total Population: ~%', total_pop;
  RAISE NOTICE '===================================';
END $$;

-- Sample query to show the data structure
SELECT
  'Sample Tabias and Kushets' AS info,
  t.name_english AS tabia,
  k.name_english AS kushet,
  k.population_estimate AS population
FROM public.tabias t
JOIN public.kushets k ON k.tabia_code = t.code
WHERE t.code IN ('KA-AGBE', 'KA-WUKRO')
ORDER BY t.name_english, k.name_english
LIMIT 10;

-- Query health facilities
SELECT
  name_english AS facility,
  facility_type,
  catchment_population,
  has_electricity,
  has_internet,
  array_length(services, 1) AS num_services
FROM public.health_facilities_kilte_awlalo
ORDER BY
  CASE facility_type
    WHEN 'General Hospital' THEN 1
    WHEN 'Health Center' THEN 2
    WHEN 'Health Post' THEN 3
  END,
  name_english;
