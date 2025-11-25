# Ethiopian HDSS Adaptation Guide

## Overview
This guide provides comprehensive recommendations for adapting the PIRL Record Linkage Software to Ethiopian Health and Demographic Surveillance System (HDSS) contexts.

---

## 1. CRITICAL BUG FIXES COMPLETED ✅

### Fixed Issues (2025-11-25)
1. **Birth Date Matching Bug** - Now correctly compares birth day/month fields
2. **Scoring Weights** - Recalibrated to sum to exactly 1.0 (was 1.55)

**New Weight Distribution:**
- Original names: 60% (first 25%, middle 10%, last 25%)
- Transliterated names: 5%
- Gender: 10%
- Birth date: 15% (day 3%, month 3%, year 9%)
- Location: 10%

---

## 2. ETHIOPIAN LINGUISTIC ADAPTATIONS

### 2.1 Name Structure
Ethiopian names follow patronymic patterns different from Western naming:

**Typical Ethiopian Name Structure:**
- **Given Name** (e.g., "Abebe")
- **Father's Name** (e.g., "Bikila") - serves as middle/family name
- **Grandfather's Name** (optional, for disambiguation)

**Database Schema Modifications Needed:**

```sql
-- Add to dss_individuals table
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS grandfather_name text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS grandfather_name_amharic text;

-- Ethiopian name fields
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS first_name_amharic text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS father_name_amharic text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS first_name_latin text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS father_name_latin text;

-- Rename for clarity
-- tl_first_name -> first_name_latin (Amharic romanized to Latin script)
-- first_name -> first_name_amharic (native Amharic script - ግዕዝ fidel)
```

### 2.2 Ethiopian Scripts Support
Ethiopia uses **Ge'ez script (Fidel)** for Amharic, Tigrinya, and other languages.

**Required PostgreSQL Extensions:**
```sql
-- Already enabled in 0001_enable_extensions.sql
-- pg_trgm - works with UTF-8 Ge'ez characters
-- unaccent - may need custom dictionary for Amharic diacritics

-- Add Amharic-specific collation
CREATE COLLATION IF NOT EXISTS amharic (provider = icu, locale = 'am-ET');
```

**Indexing for Amharic Text:**
```sql
-- GIN indexes for Amharic names (supports UTF-8 Ge'ez)
CREATE INDEX IF NOT EXISTS idx_dss_amharic_names
ON public.dss_individuals USING gin (
    (coalesce(first_name_amharic,'') || ' ' || coalesce(father_name_amharic,'') || ' ' || coalesce(grandfather_name_amharic,''))
    gin_trgm_ops
);
```

### 2.3 Multi-Language Matching
Ethiopia has 80+ languages. Priority languages for HDSS:

1. **Amharic** (አማርኛ) - Official language, ~30M speakers
2. **Oromo** (Afaan Oromoo) - ~35M speakers
3. **Tigrinya** (ትግርኛ) - ~9M speakers
4. **Somali** - ~7M speakers
5. **Afar** - ~2M speakers

**Recommended Approach:**
```sql
-- Store names in both native script AND Latin transliteration
-- Example record:
-- first_name_amharic: "አበበ"
-- first_name_latin: "Abebe"
-- father_name_amharic: "ብቂላ"
-- father_name_latin: "Bikila"

-- Update search function to handle both scripts
-- Use Latin for fuzzy matching (more consistent)
-- Use Amharic for exact matching and display
```

---

## 3. ETHIOPIAN ADMINISTRATIVE DIVISIONS

### 3.1 Current Administrative Hierarchy
Ethiopia uses a different administrative structure than the original PIRL system:

```
Country (Ethiopia)
  └─ Regional State (11 regions + 2 chartered cities)
      └─ Zone
          └─ Woreda (District)
              └─ Kebele (smallest administrative unit, ~5000 people)
                  └─ Gott/Got (sub-Kebele village/hamlet)
```

### 3.2 Database Schema Updates

```sql
-- Replace village/subvillage with Ethiopian administrative structure
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS region text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS zone text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS woreda text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS kebele text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS gott text;

-- Update generated location column
ALTER TABLE public.dss_individuals DROP COLUMN IF EXISTS location;
ALTER TABLE public.dss_individuals ADD COLUMN location text
    GENERATED ALWAYS AS (
        coalesce(region,'') || ' / ' ||
        coalesce(woreda,'') || ' / ' ||
        coalesce(kebele,'') || ' / ' ||
        coalesce(gott,'')
    ) STORED;

-- Indexes for location search
CREATE INDEX IF NOT EXISTS idx_kebele ON public.dss_individuals(kebele);
CREATE INDEX IF NOT EXISTS idx_woreda ON public.dss_individuals(woreda);
CREATE INDEX IF NOT EXISTS idx_region ON public.dss_individuals(region);
```

### 3.3 Regional States (for dropdown/validation)
```
1. Tigray
2. Afar
3. Amhara
4. Oromia
5. Somali
6. Benishangul-Gumuz
7. Southern Nations, Nationalities, and Peoples' Region (SNNPR)
8. Gambela
9. Harari
10. Sidama
11. South West Ethiopia Peoples' Region
12. Addis Ababa (chartered city)
13. Dire Dawa (chartered city)
```

---

## 4. ETHIOPIAN CALENDAR CONSIDERATIONS

### 4.1 Calendar System
Ethiopia uses the **Ethiopian Calendar (Ge'ez Calendar)**, which is ~7-8 years behind the Gregorian calendar.

**Key Differences:**
- Ethiopian year 2017 = Gregorian 2024/2025
- 13 months (12 months of 30 days + 1 month of 5-6 days)
- New Year on September 11 (Enkutatash - እንቁጣጣሽ)

### 4.2 Database Modifications

```sql
-- Add calendar type indicator
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS calendar_type text DEFAULT 'gregorian';
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS birth_day_ethiopian text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS birth_month_ethiopian text;
ALTER TABLE public.dss_individuals ADD COLUMN IF NOT EXISTS birth_year_ethiopian text;

-- Keep Gregorian for computations, Ethiopian for display/input
-- Always convert Ethiopian -> Gregorian for storage and matching
```

### 4.3 Calendar Conversion Function

```sql
-- PostgreSQL function to convert Ethiopian to Gregorian date
CREATE OR REPLACE FUNCTION ethiopian_to_gregorian(
    eth_year int,
    eth_month int,
    eth_day int
) RETURNS date AS $$
DECLARE
    greg_year int;
    greg_month int;
    greg_day int;
    jdn int; -- Julian Day Number
BEGIN
    -- Ethiopian to Julian Day Number conversion
    -- (Simplified algorithm - use full implementation in production)
    jdn := 1723856 + 365 * eth_year + eth_year / 4 + 30 * (eth_month - 1) + eth_day;

    -- Julian Day Number to Gregorian
    -- (Use standard JDN to Gregorian conversion)
    -- Return as Gregorian date
    RETURN date '0001-01-01' + (jdn - 1721426);
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

### 4.4 UI Changes Needed

```razor
<!-- Add calendar selector in Match.razor -->
<div class="col-md-2">
    <InputSelect class="form-select" @bind-Value="search.CalendarType">
        <option value="gregorian">Gregorian</option>
        <option value="ethiopian">Ethiopian (ዘመን)</option>
    </InputSelect>
</div>

<!-- Show month names based on calendar type -->
@if (search.CalendarType == "ethiopian")
{
    <!-- Ethiopian months: መስከረም, ጥቅምት, ኅዳር, ታኅሣሥ, etc. -->
}
```

---

## 5. ETHIOPIAN HEALTH SYSTEM INTEGRATION

### 5.1 Ethiopian Health Facilities
Replace generic "facility" field with Ethiopian health system hierarchy:

```sql
-- Ethiopian health facility types
CREATE TYPE health_facility_type AS ENUM (
    'PRIMARY_HOSPITAL',          -- Woreda-level (100,000 pop)
    'HEALTH_CENTER',             -- Kebele-level (25,000 pop)
    'HEALTH_POST',               -- 3,000-5,000 population
    'TERTIARY_HOSPITAL',         -- Regional referral
    'GENERAL_HOSPITAL',          -- Zonal
    'PRIVATE_CLINIC',
    'NGO_CLINIC'
);

ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS facility_type health_facility_type;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS facility_region text;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS facility_woreda text;
```

### 5.2 Ethiopian Medical Record Numbers
Ethiopian health facilities use various ID systems:

```sql
-- Update matches table with Ethiopian health IDs
ALTER TABLE public.matches DROP COLUMN IF EXISTS unique_ctcid_number; -- Tanzania-specific
ALTER TABLE public.matches DROP COLUMN IF EXISTS tgr_form_number;     -- Tanzania-specific

-- Add Ethiopian health IDs
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS emr_number text;          -- Electronic Medical Record
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS art_number text;          -- ART (Antiretroviral Therapy) ID
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS tb_registration_number text;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS pmtct_id text;            -- Prevention of Mother-to-Child Transmission
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS hiv_testing_id text;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS smartcare_id text;        -- SmartCare system ID (used in Ethiopia)
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS maternal_child_id text;   -- MCH services
```

### 5.3 Integration with Ethiopian eHealth Systems

**HMIS (Health Management Information System):**
- Ministry of Health uses **DHIS2** (District Health Information System 2)
- API integration possible for data exchange

**Recommended API Endpoints to Add:**
```csharp
// Program.cs additions
app.MapPost("/api/export/dhis2", async (DHIS2ExportRequest req) =>
{
    // Export matched records to DHIS2 format
    // DHIS2 uses JSON-based API
});

app.MapPost("/api/import/smartcare", async (SmartCareImportRequest req) =>
{
    // Import patient records from SmartCare EMR
});
```

---

## 6. HDSS-SPECIFIC FEATURES FOR ETHIOPIA

### 6.1 Vital Events Registration
Ethiopian HDSS sites track:
- **Births** (including home births)
- **Deaths** (with verbal autopsy)
- **Migrations** (in/out)
- **Marriages**
- **Pregnancies**

```sql
-- Add vital events tracking
CREATE TABLE IF NOT EXISTS public.vital_events (
    id bigserial PRIMARY KEY,
    dss_id text NOT NULL REFERENCES public.dss_individuals(dss_id),
    event_type text NOT NULL, -- BIRTH, DEATH, MIGRATION_IN, MIGRATION_OUT, MARRIAGE, PREGNANCY
    event_date date,
    event_date_ethiopian text, -- Ethiopian calendar
    registered_by text,
    registration_date timestamptz DEFAULT now(),
    verified boolean DEFAULT false,
    notes text
);
```

### 6.2 Household Tracking
HDSS tracks household composition over time:

```sql
CREATE TABLE IF NOT EXISTS public.households (
    household_id text PRIMARY KEY,
    kebele text,
    gott text,
    house_number text,
    head_of_household_dss_id text REFERENCES public.dss_individuals(dss_id),
    creation_date date,
    last_updated timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.household_members (
    id bigserial PRIMARY KEY,
    household_id text REFERENCES public.households(household_id),
    dss_id text REFERENCES public.dss_individuals(dss_id),
    relationship_to_head text, -- spouse, child, parent, sibling, other
    join_date date,
    leave_date date,
    residence_status text -- permanent, temporary, migrated
);

-- This enables matching by household context
-- e.g., "Find person named Abebe in household with head Bekele"
```

---

## 7. SCORING WEIGHT OPTIMIZATION FOR ETHIOPIAN CONTEXT

### 7.1 Recommended Weight Adjustments

Ethiopian names have different patterns than the original Tanzania HDSS context:

```sql
-- Recommended weights for Ethiopian HDSS:
-- (Replace in 0003_functions.sql)

(
    0.30*sim_fn +                    -- Given name: 30% (very important)
    0.25*sim_father_name +           -- Father's name: 25% (patronymic is key)
    0.05*sim_grandfather_name +      -- Grandfather: 5% (less common but useful)
    0.10*sim_gender +                -- Gender: 10%
    0.02*sim_bday + 0.02*sim_bmonth + 0.08*sim_byear + -- Birth date: 12%
    0.08*sim_kebele +                -- Kebele: 8% (more important in rural HDSS)
    0.05*sim_gott +                  -- Gott/village: 5%
    0.05*sim_household              -- Household context: 5%
) as score
-- Total: 100%
```

**Rationale:**
- Ethiopian names are less variable than Tanzanian (fewer middle names)
- Father's name is critical for disambiguation
- Kebele location is highly predictive in rural HDSS sites
- Household membership can resolve ambiguous matches

### 7.2 Age-Based Weight Adjustment

```sql
-- For elderly individuals, increase location weight (less mobile)
-- For young adults, decrease location weight (more mobile)

CASE
    WHEN age < 18 THEN 0.08 * sim_kebele
    WHEN age BETWEEN 18 AND 35 THEN 0.05 * sim_kebele -- more migration
    WHEN age > 35 THEN 0.10 * sim_kebele -- more stable residence
END
```

---

## 8. DATA PRIVACY AND SECURITY (ETHIOPIAN CONTEXT)

### 8.1 Legal Framework
- **Ethiopian Data Protection Law** (draft as of 2024)
- **Health Information Privacy Regulations** (MoH)
- Must comply with international standards (GDPR if partnering with EU institutions)

### 8.2 Security Enhancements Needed

```csharp
// Add authentication middleware
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = builder.Configuration["Auth:Authority"];
        options.Audience = builder.Configuration["Auth:Audience"];
    });

// Add authorization policies
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("CanViewPII", policy =>
        policy.RequireClaim("role", "doctor", "nurse", "researcher"));

    options.AddPolicy("CanLinkRecords", policy =>
        policy.RequireClaim("role", "data_manager", "researcher"));
});

// Apply to endpoints
app.MapPost("/api/search", async (SearchRequest req) =>
{
    // ... existing code
}).RequireAuthorization("CanViewPII");

app.MapPost("/api/matches", async (AssignMatchRequest req) =>
{
    // ... existing code
}).RequireAuthorization("CanLinkRecords");
```

### 8.3 Audit Logging

```sql
-- Track all record linkages for audit
CREATE TABLE IF NOT EXISTS public.audit_log (
    id bigserial PRIMARY KEY,
    user_email text NOT NULL,
    action text NOT NULL, -- SEARCH, MATCH_ASSIGN, MATCH_UPDATE, EXPORT
    dss_id text,
    clinic_id text,
    ip_address inet,
    timestamp timestamptz DEFAULT now(),
    details jsonb
);

-- Add trigger to log all matches
CREATE OR REPLACE FUNCTION log_match_assignment()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.audit_log (user_email, action, dss_id, clinic_id, details)
    VALUES (
        current_setting('app.current_user', true),
        'MATCH_ASSIGN',
        NEW.dss_id,
        NEW.record_no,
        to_jsonb(NEW)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER match_assignment_audit
AFTER INSERT ON public.matches
FOR EACH ROW EXECUTE FUNCTION log_match_assignment();
```

---

## 9. DEPLOYMENT RECOMMENDATIONS

### 9.1 Hosting Options for Ethiopian Context

**Option 1: On-Premise (Recommended for sensitive health data)**
- Host at Ethiopian Public Health Institute (EPHI)
- Host at university data centers (AAU, Jimma, Gondar)
- Ensures data sovereignty
- Better compliance with Ethiopian regulations

**Option 2: Cloud (with data residency)**
- **AWS Africa (Cape Town)** - nearest AWS region
- **Azure South Africa** - has data residency options
- **Local Ethiopian cloud providers** (if available)

**Infrastructure Requirements:**
```yaml
# Docker Compose for deployment
version: '3.8'
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ethiopian_hdss
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./supabase/migrations:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"

  api:
    build: ./PremiumMatcher/PremiumMatcher.Api
    environment:
      SUPABASE_DB_URL: "Host=postgres;Database=ethiopian_hdss;Username=${DB_USER};Password=${DB_PASSWORD}"
      ASPNETCORE_ENVIRONMENT: Production
    ports:
      - "5151:8080"
    depends_on:
      - postgres

  web:
    build: ./PremiumMatcher/PremiumMatcher.Web
    environment:
      API_BASE_URL: "http://api:8080"
    ports:
      - "8080:80"
    depends_on:
      - api

volumes:
  pgdata:
```

### 9.2 Offline Capability (Critical for Rural Ethiopia)

Many HDSS sites in Ethiopia have unreliable internet. Add offline-first capability:

```csharp
// In Blazor WASM app
// Add service worker for offline caching
// wwwroot/service-worker.js

// Cache API calls for offline use
self.addEventListener('fetch', (event) => {
    if (event.request.url.includes('/api/search')) {
        event.respondWith(
            caches.match(event.request)
                .then(response => response || fetch(event.request))
        );
    }
});

// Use IndexedDB for local data storage
// When internet returns, sync to server
```

**Progressive Web App (PWA) Enhancements:**
```json
// wwwroot/manifest.json
{
    "name": "Ethiopian HDSS Record Matcher",
    "short_name": "HDSS Matcher",
    "start_url": "/",
    "display": "standalone",
    "background_color": "#ffffff",
    "theme_color": "#009639",  // Ethiopian flag green
    "icons": [
        {
            "src": "icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
        }
    ],
    "offline_enabled": true
}
```

---

## 10. UI/UX LOCALIZATION

### 10.1 Language Support

```razor
<!-- Add language selector -->
@inject IStringLocalizer<Match> Localizer

<div class="language-selector">
    <select @onchange="ChangeLanguage">
        <option value="en">English</option>
        <option value="am">አማርኛ (Amharic)</option>
        <option value="om">Afaan Oromoo</option>
        <option value="ti">ትግርኛ (Tigrinya)</option>
    </select>
</div>

<!-- Use localized strings -->
<h3>@Localizer["RecordMatching"]</h3>
```

**Resource Files Needed:**
```
Resources/
  ├── Match.en.resx     (English)
  ├── Match.am.resx     (Amharic)
  ├── Match.om.resx     (Oromo)
  └── Match.ti.resx     (Tigrinya)
```

### 10.2 Right-to-Left (RTL) Support

Ethiopian scripts are left-to-right, but if supporting Somali region (Arabic script):

```css
/* wwwroot/css/app.css */
[dir="rtl"] {
    direction: rtl;
    text-align: right;
}

[dir="rtl"] .form-control {
    text-align: right;
}
```

### 10.3 Ethiopian-Specific UI Elements

```razor
<!-- Color scheme using Ethiopian flag colors -->
<style>
    :root {
        --ethiopian-green: #009639;
        --ethiopian-yellow: #FEDD00;
        --ethiopian-red: #DA121A;
    }

    .btn-primary {
        background-color: var(--ethiopian-green);
    }

    .alert-warning {
        background-color: var(--ethiopian-yellow);
    }
</style>

<!-- Ethiopian date display -->
<div class="ethiopian-date">
    ዛሬ: @EthiopianDate.Today.ToString("d MMMM yyyy", new CultureInfo("am-ET"))
</div>
```

---

## 11. MATCHING ALGORITHM ENHANCEMENTS

### 11.1 Phonetic Matching for Ethiopian Languages

Amharic phonetics differ significantly. Consider adding:

```sql
-- Soundex-like algorithm for Amharic
-- Groups similar-sounding Ge'ez characters
CREATE OR REPLACE FUNCTION amharic_soundex(text) RETURNS text AS $$
BEGIN
    -- Map similar consonants
    -- ሀ, ሐ, ኀ, ሃ -> H
    -- ተ, ጠ -> T
    -- ሰ, ሸ, ጸ -> S
    -- etc.
    -- Return standardized phonetic code
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Use in search function
similarity(amharic_soundex(_first_name), amharic_soundex(q.first_name))
```

### 11.2 Family-Based Matching

Ethiopian families often share compound names:

```sql
-- Add family matching bonus
WITH family_score AS (
    SELECT
        CASE
            WHEN q.father_name = _father_name THEN 0.15  -- Same father
            WHEN q.household_id = _household_id THEN 0.10 -- Same household
            ELSE 0
        END as family_bonus
    FROM q
)
-- Add family_bonus to overall score
```

---

## 12. PERFORMANCE OPTIMIZATIONS FOR HDSS SCALE

### 12.1 Expected Data Volumes

Ethiopian HDSS sites vary in size:
- **Small site**: 10,000-50,000 individuals
- **Medium site**: 50,000-150,000 individuals
- **Large site**: 150,000-500,000 individuals
- **National aggregation**: 5-10 million records

### 12.2 Database Partitioning

```sql
-- Partition by region for faster queries
CREATE TABLE public.dss_individuals_partitioned (
    -- all columns
) PARTITION BY LIST (region);

CREATE TABLE dss_individuals_tigray PARTITION OF dss_individuals_partitioned
    FOR VALUES IN ('Tigray');

CREATE TABLE dss_individuals_amhara PARTITION OF dss_individuals_partitioned
    FOR VALUES IN ('Amhara');

-- etc. for each region
```

### 12.3 Materialized Views for Common Searches

```sql
-- Cache frequently searched names
CREATE MATERIALIZED VIEW common_names AS
SELECT
    first_name_latin,
    father_name_latin,
    COUNT(*) as frequency
FROM public.dss_individuals
GROUP BY first_name_latin, father_name_latin
HAVING COUNT(*) > 10;

CREATE INDEX idx_common_names ON common_names(first_name_latin, father_name_latin);

-- Refresh periodically
REFRESH MATERIALIZED VIEW CONCURRENTLY common_names;
```

---

## 13. TRAINING AND DOCUMENTATION

### 13.1 User Manual (Amharic)

Create comprehensive documentation in Amharic:

```markdown
# የህብረተሰብ ጤና እና የስነ-ሕዝብ ክትትል ስርዓት መመሪያ
## (HDSS Record Matching User Manual)

### ምዕራፍ 1: መግቢያ (Chapter 1: Introduction)
ይህ ሶፍትዌር የህብረተሰብ ጤና ክትትል መረጃዎችን ከጤና ተቋም መዝገቦች ጋር ለማገናኘት ያስችላል።
(This software enables linking of HDSS records with health facility records.)

### ምዕራፍ 2: እንዴት ይሠራል (Chapter 2: How It Works)
...
```

### 13.2 Video Tutorials

Record video tutorials in:
- Amharic (for most users)
- English (for technical staff)
- Local languages (for specific HDSS sites)

### 13.3 Training Curriculum

```markdown
# 3-Day Training Program for HDSS Data Managers

## Day 1: Introduction and Basic Operations
- Understanding record linkage concepts
- System overview and navigation
- Basic search operations
- Practice with sample data

## Day 2: Advanced Matching and Quality Control
- Understanding match scores
- Handling ambiguous matches
- Quality control procedures
- Handling special cases (twins, name changes, etc.)

## Day 3: Data Management and Troubleshooting
- Data import/export
- Report generation
- Common issues and solutions
- Hands-on practice with real HDSS data
```

---

## 14. QUALITY CONTROL AND VALIDATION

### 14.1 Match Quality Metrics

```sql
-- Track matching performance
CREATE TABLE IF NOT EXISTS public.match_quality_metrics (
    id bigserial PRIMARY KEY,
    date date DEFAULT CURRENT_DATE,
    total_searches int,
    matches_with_score_high int,      -- score >= 0.8
    matches_with_score_medium int,    -- 0.5 <= score < 0.8
    matches_with_score_low int,       -- score < 0.5
    manual_review_required int,
    false_positives_reported int,
    average_score numeric,
    kebele text
);

-- Daily quality report
CREATE OR REPLACE FUNCTION daily_match_quality_report()
RETURNS TABLE (
    kebele text,
    avg_score numeric,
    high_quality_pct numeric,
    review_needed int
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.kebele,
        AVG(m.score)::numeric(5,3),
        (COUNT(*) FILTER (WHERE score >= 0.8)::numeric / COUNT(*) * 100)::numeric(5,2),
        COUNT(*) FILTER (WHERE score < 0.5)::int
    FROM public.match_quality_metrics m
    WHERE date >= CURRENT_DATE - INTERVAL '7 days'
    GROUP BY m.kebele;
END;
$$ LANGUAGE plpgsql;
```

### 14.2 Duplicate Detection

```sql
-- Find potential duplicate HDSS IDs
CREATE OR REPLACE VIEW potential_duplicates AS
SELECT
    a.dss_id as dss_id_1,
    b.dss_id as dss_id_2,
    similarity(a.first_name_latin, b.first_name_latin) as name_sim,
    a.birth_year,
    b.birth_year,
    a.kebele
FROM public.dss_individuals a
JOIN public.dss_individuals b ON
    a.dss_id < b.dss_id AND
    a.kebele = b.kebele AND
    similarity(
        a.first_name_latin || ' ' || a.father_name_latin,
        b.first_name_latin || ' ' || b.father_name_latin
    ) > 0.85 AND
    ABS(COALESCE(a.birth_year::int, 0) - COALESCE(b.birth_year::int, 0)) <= 1;
```

---

## 15. MIGRATION PLAN FROM CURRENT SYSTEM

### Phase 1: Preparation (2-4 weeks)
- [ ] Assess current HDSS data structure
- [ ] Map existing fields to new schema
- [ ] Test calendar conversion (Ethiopian ↔ Gregorian)
- [ ] Translate UI to Amharic
- [ ] Prepare training materials

### Phase 2: Pilot (1-2 months)
- [ ] Select one HDSS site for pilot
- [ ] Import historical data
- [ ] Train data managers
- [ ] Run parallel with existing system
- [ ] Collect feedback and refine

### Phase 3: Rollout (3-6 months)
- [ ] Deploy to remaining HDSS sites
- [ ] Provide ongoing support
- [ ] Monitor performance metrics
- [ ] Iterate based on user feedback

### Phase 4: Integration (6-12 months)
- [ ] Connect to national HMIS/DHIS2
- [ ] Integrate with SmartCare EMR
- [ ] Enable cross-site linkage
- [ ] Implement advanced analytics

---

## 16. COST ESTIMATES

### Infrastructure (Annual)
- **On-premise server**: $5,000-$10,000 (one-time)
- **Cloud hosting** (AWS/Azure): $1,200-$3,600/year
- **Database storage** (500GB): $500-$1,000/year
- **Backup and disaster recovery**: $500-$1,500/year

### Personnel (per HDSS site)
- **Data manager training**: $500-$1,000 (one-time)
- **Ongoing support**: $200-$500/month
- **Technical maintenance**: $1,000-$2,000/year

### Development (Customization)
- **Ethiopian adaptations**: $10,000-$20,000 (one-time)
- **Amharic localization**: $3,000-$5,000
- **Calendar integration**: $2,000-$3,000
- **Testing and QA**: $3,000-$5,000

**Total First Year (per site)**: ~$25,000-$50,000
**Subsequent Years**: ~$5,000-$10,000

---

## 17. CONTACT AND SUPPORT

### Technical Support
- **Ethiopian Public Health Institute (EPHI)** - ephi@ethionet.et
- **Addis Ababa University, School of Public Health**
- **International partnerships**: LSHTM, CDC Ethiopia, WHO Ethiopia

### Development Community
- GitHub Issues: Report bugs and feature requests
- Email support: (configure for your organization)
- Training workshops: Quarterly at EPHI

---

## 18. APPENDICES

### Appendix A: Ethiopian Names Reference

**Common Amharic Names (Male):**
- Abebe (አበበ), Bekele (በቀለ), Desta (ደስታ), Gebre (ገብረ), Haile (ኃይሌ)

**Common Amharic Names (Female):**
- Almaz (አልማዝ), Birtukan (ብርቱካን), Hanna (ሃና), Mulu (ሙሉ), Tigist (ጥገኝ)

**Name Variations:**
- Same name, different spelling: Abebe / Ababa / Ababa
- Names with religious prefixes: Gebre-Mariam, Haile-Selassie
- Compound names: Abebech (feminine of Abebe)

### Appendix B: Kebele Codes Sample

```csv
region,zone,woreda,kebele,kebele_code
Amhara,North Gondar,Gondar Zuria,Azezo,AM-NG-GZ-001
Amhara,North Gondar,Gondar Zuria,Maraki,AM-NG-GZ-002
Oromia,East Shewa,Adama,Bole,OR-ES-AD-001
SNNPR,Sidama,Hawassa Zuria,Alamura,SN-SI-HZ-001
```

### Appendix C: SQL Migration Script Template

```sql
-- Full migration from Tanzania PIRL to Ethiopian HDSS
-- Execute in order: 0001, 0002, 0003, then this script

-- 1. Backup existing data
CREATE TABLE dss_individuals_backup AS SELECT * FROM dss_individuals;

-- 2. Add Ethiopian columns
\i ethiopian_adaptations.sql

-- 3. Migrate data
UPDATE dss_individuals SET
    first_name_latin = first_name,
    father_name_latin = middle_name,
    kebele = village,
    gott = subvillage;

-- 4. Validate
SELECT COUNT(*) FROM dss_individuals WHERE kebele IS NOT NULL;

-- 5. Update search function
\i 0003_functions_ethiopian.sql
```

---

## CONCLUSION

This adaptation guide provides a comprehensive roadmap for deploying the PIRL Record Linkage Software in Ethiopian HDSS contexts. Key priorities:

1. ✅ **Critical bugs fixed** - System now works correctly
2. 🔤 **Language support** - Amharic, Oromo, Tigrinya
3. 🗓️ **Calendar integration** - Ethiopian calendar support
4. 📍 **Administrative divisions** - Region → Woreda → Kebele → Gott
5. 🏥 **Health system integration** - Ethiopian facility types and IDs
6. 🔒 **Security & privacy** - Compliance with Ethiopian regulations
7. 📴 **Offline capability** - Critical for rural areas
8. 📊 **Quality control** - Monitoring and validation

**Next Steps:**
1. Review this guide with EPHI and HDSS site leaders
2. Prioritize features based on specific site needs
3. Begin with pilot implementation at one HDSS site
4. Iterate based on real-world feedback
5. Scale to additional sites

**Success Metrics:**
- Match accuracy > 90%
- User satisfaction > 80%
- Reduced linkage time by 50%
- Increased data quality and completeness
