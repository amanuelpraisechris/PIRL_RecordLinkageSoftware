# Month 2 Week 1-2 Testing Guide
## Ethiopian HDSS Record Linkage System - Kilte Awlalo

---

## 📋 Prerequisites

Before testing, ensure you have:

1. **Database configured with migrations:**
   ```bash
   # Set your Supabase connection string
   export SUPABASE_DB_URL="postgresql://user:password@host:port/database"

   # Or create .env file
   echo 'SUPABASE_DB_URL="postgresql://user:password@host:port/database"' > .env

   # Apply all migrations
   psql "$SUPABASE_DB_URL" -f supabase/migrations/0001_extensions.sql
   psql "$SUPABASE_DB_URL" -f supabase/migrations/0002_schema.sql
   psql "$SUPABASE_DB_URL" -f supabase/migrations/0003_functions.sql
   psql "$SUPABASE_DB_URL" -f supabase/migrations/0005_kilte_awlalo_locations.sql
   psql "$SUPABASE_DB_URL" -f supabase/migrations/0006_sample_individuals_kilte_awlalo.sql
   ```

2. **Verify database setup:**
   ```sql
   -- Should show 10 Tabias
   SELECT COUNT(*) FROM public.tabias;

   -- Should show 33 Kushets
   SELECT COUNT(*) FROM public.kushets;

   -- Should show 16 health facilities
   SELECT COUNT(*) FROM public.health_facilities_kilte_awlalo;

   -- Should show 52 individuals
   SELECT COUNT(*) FROM public.dss_individuals;
   ```

3. **API and Web servers running:**
   ```bash
   # Terminal 1: Start API
   cd PremiumMatcher/PremiumMatcher.Api
   source ../../.env 2>/dev/null || true
   dotnet run
   # Should see: Now listening on: http://localhost:5000

   # Terminal 2: Start Web
   cd PremiumMatcher/PremiumMatcher/PremiumMatcher.Web
   dotnet run
   # Should see: Now listening on: http://localhost:5001
   ```

---

## 🧪 Test Cases

### Test 1: API Location Endpoints ✅

**Verify the Kilte Awlalo location API endpoints work correctly**

```bash
# Test 1.1: Get all Tabias
curl http://localhost:5000/api/kilte-awlalo/tabias
# Expected: JSON array with 10 Tabias (KA-AGBE, KA-WUKRO, etc.)

# Test 1.2: Get all Kushets
curl http://localhost:5000/api/kilte-awlalo/kushets
# Expected: JSON array with 33 Kushets

# Test 1.3: Get Kushets for specific Tabia
curl "http://localhost:5000/api/kilte-awlalo/kushets?tabiaCode=KA-AGBE"
# Expected: JSON array with 4 Kushets (KA-AGBE-01, KA-AGBE-02, KA-AGBE-03, KA-AGBE-04)

# Test 1.4: Get all health facilities
curl http://localhost:5000/api/kilte-awlalo/facilities
# Expected: JSON array with 16 facilities

# Test 1.5: Get Health Centers only
curl "http://localhost:5000/api/kilte-awlalo/facilities?facilityType=Health%20Center"
# Expected: JSON array with 5 Health Centers

# Test 1.6: Get summary statistics
curl http://localhost:5000/api/kilte-awlalo/stats
# Expected: {"tabiaCount":10,"kushetCount":33,"facilityCount":16,"totalPopulation":67000,...}

# Test 1.7: Get location view
curl http://localhost:5000/api/kilte-awlalo/locations/view
# Expected: JSON array with hierarchical location data
```

**Success Criteria:**
- ✅ All endpoints return 200 OK
- ✅ JSON responses contain correct data
- ✅ Trilingual names present (Tigrinya, Amharic, English)
- ✅ Population estimates included

---

### Test 2: Language Switcher Component 🌐

**Navigate to:** http://localhost:5001/match

**Steps:**
1. Look for language dropdown in header (flag icon + language name)
2. Default language should be Tigrinya (ትግርኛ 🇪🇹)
3. Click dropdown and select English
4. Verify UI labels change to English
5. Select Amharic (አማርኛ)
6. Verify UI labels change to Amharic
7. Reload page
8. Verify language preference persisted (still Amharic)

**Success Criteria:**
- ✅ Language switcher visible in header
- ✅ All 3 languages available (Tigrinya, Amharic, English)
- ✅ UI updates immediately on language change
- ✅ Preference saved to localStorage (key: `hdss_language`)
- ✅ Preference persists across page reloads
- ✅ Ethiopian flag (🇪🇹) shown for Tigrinya/Amharic
- ✅ UK flag (🇬🇧) shown for English

**Check localStorage:**
```javascript
// Open browser DevTools Console (F12)
localStorage.getItem('hdss_language')
// Expected: "ti", "am", or "en"
```

---

### Test 3: Ethiopian Date Picker Component 📅

**Navigate to:** http://localhost:5001/match

**Test 3.1: Ethiopian Calendar Input**
1. Set Calendar Type to "Ethiopian" (ናይ ኢትዮጵያ ዘመን)
2. Enter Day: 15
3. Select Month: 3 - ሕዳር (Hidar)
4. Enter Year: 2017 (Ethiopian)
5. Verify conversion hint shows: "EC: 2017 ≈ AD: 2025"

**Test 3.2: Gregorian Calendar Input**
1. Switch Calendar Type to "Gregorian"
2. Enter Day: 24
3. Select Month: November
4. Enter Year: 2024
5. Verify no conversion hint shown

**Test 3.3: Age-Only Mode**
1. Check "Age only (Birth Year approximate)"
2. Verify Day and Month fields are cleared/disabled
3. Enter Year only: 2000
4. Uncheck Age-only
5. Verify Day and Month fields enabled again

**Test 3.4: Ethiopian Month Names**
- Verify all 13 months appear in dropdown:
  - መስከረም, ጥቅምቲ, ሕዳር, ታሕሳስ, ጥሪ, የካቲት, መጋቢት, ሚያዝያ, ግንቦት, ሰነ, ሐምለ, ነሐሴ, **ጳጉሜ** (13th month)

**Success Criteria:**
- ✅ Calendar type toggle works (Ethiopian ↔ Gregorian)
- ✅ 13 Ethiopian months with Ethiopic script
- ✅ Year conversion hint accurate (±8 years)
- ✅ Age-only mode clears day/month
- ✅ Responsive on mobile
- ✅ Labels change with language switcher

---

### Test 4: Location Picker Component 📍

**Navigate to:** http://localhost:5001/match

**Test 4.1: Cascading Selection**
1. Tabia dropdown should be enabled
2. Kushet dropdown should be **disabled** (no Tabia selected)
3. Select Tabia: "Agbe" (ኣግበ)
4. Verify Kushet dropdown now **enabled**
5. Verify Kushet dropdown shows only Agbe Kushets (4 options)
6. Select Kushet: "Agbe" (ኣግበ)
7. Verify population info appears: "📍 Agbe - Population: ~7200 | Agbe - ~2400"

**Test 4.2: Different Tabia**
1. Change Tabia to "Wukro Town" (ውቕሮ)
2. Verify Kushet dropdown resets (no selection)
3. Verify Kushets now show Wukro Kebeles (5 options: Kebele 01-05)
4. Select "Kebele 01"
5. Verify population info updates

**Test 4.3: Gott (Sub-village) Input**
1. Enter free text in Gott field: "Hayelom"
2. Verify accepts any text (no validation)

**Test 4.4: Woreda Field**
1. Verify Woreda field shows "Kilte Awlalo"
2. Verify field is **read-only** (fixed value)

**Test 4.5: All Tabias Present**
- Verify all 10 Tabias available:
  - Agbe, Wukro Town, Chele, Dera, Endahwukro, Genfel, Hareza, Shibdih, Tsaeda Emba, Zaba Guna

**Success Criteria:**
- ✅ Tabia dropdown has all 10 options
- ✅ Kushet dropdown cascades (filtered by Tabia)
- ✅ Kushet disabled until Tabia selected
- ✅ Kushet resets when Tabia changes
- ✅ Population estimates display correctly
- ✅ Trilingual names (change with language switcher)
- ✅ Gott accepts free text
- ✅ Responsive on mobile

---

### Test 5: Integrated Search with Location Codes 🔍

**Navigate to:** http://localhost:5001/match

**Test 5.1: Exact Name + Location Match**
1. Enter Given Name: "Tesfay"
2. Enter Father's Name: "Gebrehiwot"
3. Enter Grandfather's Name: "Haile"
4. Select Gender: Male
5. Select Tabia: "Agbe" (ኣግበ)
6. Select Kushet: "Agbe" (KA-AGBE-01)
7. Check all search criteria checkboxes
8. Click "Search" (ድለ)

**Expected Result:**
- Should find: **KA-AGBE-001** (Tesfay Gebrehiwot Haile, M, 15/3/1985)
- Score: **≥0.9** (excellent match - green badge 🟢)
- Location: "KA-AGBE / KA-AGBE-01"

**Test 5.2: Fuzzy Name Match (Typo)**
1. Clear form
2. Enter Given Name: "Tesfy" (typo - missing 'a')
3. Enter Father's Name: "Gebrehiot" (typo - missing 'w')
4. Enter Grandfather's Name: "Haile"
5. Select Tabia: "Agbe"
6. Check name checkboxes only
7. Click "Search"

**Expected Result:**
- Should find: **KA-AGBE-011** (Tesfy Gebrehiot Haile, M)
- Score: **0.7-0.9** (good match - yellow badge 🟡)
- Demonstrates fuzzy matching tolerance

**Test 5.3: Birth Date Matching**
1. Clear form
2. Enter Given Name: "Alem"
3. Set Calendar to Ethiopian
4. Enter Day: 22, Month: 11 (ሐምለ), Year: 1982 EC
5. Select Gender: Female
6. Check Given Name, Birth Date, and Gender
7. Click "Search"

**Expected Result:**
- Should find: **KA-AGBE-002** (Alem Tekle Gebremariam, F, 22/7/1990)
- Birth date boost should increase score
- Note: Need to convert 1982 EC → ~1990 AD

**Test 5.4: Location-Only Search**
1. Clear form
2. Select Tabia: "Wukro Town"
3. Select Kushet: "Kebele 01" (KA-WUKRO-01)
4. Check Location checkboxes only
5. Click "Search"

**Expected Result:**
- Should find: **3 individuals** in KA-WUKRO-01
  - KA-WUKRO-001 (Berhane Haile Gebru)
  - KA-WUKRO-002 (Yordanos Mekonnen Aregay)
  - KA-WUKRO-011 (Tesfay G Haile)
- Sorted by name similarity score

**Test 5.5: No Results**
1. Clear form
2. Enter Given Name: "NonexistentName"
3. Select Tabia: "Tsaeda Emba" (no sample data)
4. Click "Search"

**Expected Result:**
- Message: "ውጽኢት የለን" (No results) - in Tigrinya
- No error, clean empty state

**Success Criteria:**
- ✅ Search returns matching individuals
- ✅ Location codes properly filter results
- ✅ Score badges color-coded (green/yellow/orange)
- ✅ Fuzzy matching works (tolerates typos)
- ✅ Birth date matching functional
- ✅ Location-only search works
- ✅ No results handled gracefully
- ✅ Results show all name parts (Given/Father's/Grandfather's)

---

### Test 6: Match Assignment with Health Facilities 💊

**Navigate to:** http://localhost:5001/match

**Test 6.1: Facility Selector**
1. Perform search (Test 5.1 above)
2. Click "Select" on a candidate
3. Verify Match Assignment form appears
4. Check Health Facility dropdown:
   - Should have 3 optgroups: General Hospital (1), Health Center (5), Health Post (10)
   - Facilities should show in selected language

**Test 6.2: Trilingual Facility Names**
1. Switch language to Tigrinya
2. Verify facilities show Tigrinya names (ማእከል ጥዕና ኣግበ)
3. Switch to Amharic
4. Verify facilities show Amharic names (የኣግበ ጤና ማዕከል)
5. Switch to English
6. Verify facilities show English names (Agbe Health Center)

**Test 6.3: Complete Match Assignment**
1. Perform search (Test 5.1)
2. Select candidate KA-AGBE-001
3. Fill in required fields:
   - Health Facility: **Wukro General Hospital**
   - Record Number: **MRN-2024-001**
4. Optional Ethiopian Health IDs:
   - MRN Number: **WGH-MRN-123456**
   - ART Number: **WGH-ART-789012**
5. Click "Assign Match" (ምድማር ኣቐምጥ)

**Expected Result:**
- Success message: "Match assigned successfully"
- Match saved to database
- Form clears, ready for next match

**Test 6.4: All Facilities Present**
- Verify all 16 Kilte Awlalo facilities available:

**General Hospital (1):**
- WGH-001: Wukro General Hospital

**Health Centers (5):**
- HC-AGBE: Agbe Health Center
- HC-WUKRO: Wukro Town Health Center
- HC-CHELE: Chele Health Center
- HC-HAREZA: Hareza Health Center
- HC-ENDRA: Endahwukro Health Center

**Health Posts (10):**
- HP-AGBE, HP-WUKRO, HP-CHELE, HP-DERA, HP-ENDRA, HP-GENFEL, HP-HAREZA, HP-SHIBDIH, HP-TSAEDA, HP-ZABA

**Success Criteria:**
- ✅ All 16 facilities present and grouped correctly
- ✅ Facility names trilingual (change with language)
- ✅ Match assignment saves successfully
- ✅ Ethiopian Health ID fields accept input
- ✅ Required fields validated (Facility, Record Number)
- ✅ Form clears after successful assignment

---

## 🎯 Acceptance Criteria

### Must Pass All:

- ✅ **API Endpoints:** All 5 location endpoints return correct data
- ✅ **Language Switcher:** All 3 languages work, preference persists
- ✅ **Ethiopian Calendar:** 13 months, year conversion, age-only mode
- ✅ **Location Picker:** Cascading Tabia→Kushet, 10 Tabias + 33 Kushets
- ✅ **Search with Codes:** Location codes properly filter results
- ✅ **Match Assignment:** All 16 facilities available, trilingual names
- ✅ **Mobile Responsive:** All components work on 375px width screens
- ✅ **No Console Errors:** Browser DevTools Console clean (no red errors)

---

## 🐛 Known Issues / Limitations

1. **Database Connection Required:**
   - User must set up `SUPABASE_DB_URL` environment variable
   - No embedded/local database yet
   - Instructions provided in Prerequisites

2. **Sample Data Limited:**
   - Only 52 individuals (8 of 10 Tabias)
   - Tsaeda and Zaba Tabias reserved for testing
   - Real deployment needs full HDSS census data

3. **LocationPicker Hardcoded:**
   - Location data embedded in component (not loaded from API)
   - Good for offline-first, but harder to update
   - Month 3 enhancement: Load from API with offline cache

4. **No Backend Localization Yet:**
   - Match.Enhanced.razor uses placeholder `GetLabel()` method
   - Should load from .resx files in future
   - Current: Returns keys as-is if not translated

5. **Ethiopian Calendar Conversion:**
   - Year conversion is approximate (±8 years depending on month)
   - Full conversion library needed for accurate date handling
   - Current: Simple approximation for MVP

---

## 📚 Next Steps (Month 2 Week 3-4)

After successful testing, proceed to:

1. **Enhanced Name Matching:**
   - Abbreviation expansion (G/ → Gebre-)
   - Common name variants
   - Phonetic matching for Ethiopic script

2. **Performance Testing:**
   - Test with 1,000+ individuals
   - Measure search response time
   - Optimize database indexes

3. **User Acceptance Testing (UAT):**
   - Deploy to staging environment
   - Training for Wukro Hospital staff
   - Collect feedback on UI/UX

4. **Documentation:**
   - User manual (Tigrinya + English)
   - Admin guide for database setup
   - Video tutorials for health workers

---

## 🔧 Troubleshooting

### API Not Starting
```bash
# Check environment variable
echo $SUPABASE_DB_URL

# Verify database accessible
psql "$SUPABASE_DB_URL" -c "SELECT version();"

# Check port not in use
lsof -i :5000
```

### Web Not Loading Components
```bash
# Verify component files exist
ls PremiumMatcher/PremiumMatcher/PremiumMatcher.Web/Components/

# Check for compilation errors
dotnet build PremiumMatcher/PremiumMatcher/PremiumMatcher.Web/PremiumMatcher.Web.csproj
```

### Search Returns 0 Results
```sql
-- Check sample data loaded
SELECT COUNT(*) FROM public.dss_individuals;

-- Verify location codes
SELECT village, subvillage, COUNT(*)
FROM public.dss_individuals
GROUP BY village, subvillage;

-- Check search function exists
SELECT routine_name FROM information_schema.routines
WHERE routine_name = 'search_candidates';
```

### Language Not Changing
```javascript
// Check localStorage in browser DevTools Console
localStorage.getItem('hdss_language')

// Clear and retry
localStorage.removeItem('hdss_language')
location.reload()
```

---

## ✅ Testing Sign-Off

**Tester Name:** _________________________

**Date:** _________________________

**Environment:**
- OS: _______________
- Browser: _______________
- Database: _______________

**Results:**
- [ ] All API endpoints pass (Test 1)
- [ ] Language switcher works (Test 2)
- [ ] Ethiopian date picker functional (Test 3)
- [ ] Location picker cascading works (Test 4)
- [ ] Search with location codes accurate (Test 5)
- [ ] Match assignment with facilities complete (Test 6)

**Overall Status:** ⬜ PASS | ⬜ FAIL (with issues documented)

**Comments:**
_______________________________________________________________
_______________________________________________________________
