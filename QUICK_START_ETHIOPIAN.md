# Quick Start Guide - Ethiopian HDSS Deployment

This guide helps you get the Ethiopian HDSS Record Linkage System running quickly.

---

## Prerequisites

Before you begin, ensure you have:

- [x] **PostgreSQL 14+** installed
- [x] **.NET 9 SDK** installed
- [x] **Git** installed
- [x] Basic command line knowledge

### Install Prerequisites (Ubuntu/Debian)

```bash
# PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib

# .NET 9 SDK
wget https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 9.0

# Git (if not installed)
sudo apt install git
```

### Install Prerequisites (macOS)

```bash
# PostgreSQL
brew install postgresql@16
brew services start postgresql@16

# .NET 9 SDK
brew install dotnet

# Git
brew install git
```

### Install Prerequisites (Windows)

1. Download and install [PostgreSQL](https://www.postgresql.org/download/windows/)
2. Download and install [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
3. Download and install [Git](https://git-scm.com/download/win)

---

## Option 1: Automated Deployment (Recommended)

### Step 1: Clone Repository

```bash
git clone https://github.com/amanuelpraisechris/PIRL_RecordLinkageSoftware.git
cd PIRL_RecordLinkageSoftware
```

### Step 2: Checkout Ethiopian Branch

```bash
git checkout claude/review-software-01XkQ3XuEJUirsHE6AnmA9qT
```

### Step 3: Run Deployment Script

```bash
./deploy-ethiopian.sh
```

The script will:
- ✅ Check prerequisites
- ✅ Create database
- ✅ Apply migrations (with bug fixes)
- ✅ Load sample Ethiopian data
- ✅ Configure API
- ✅ Build application

### Step 4: Start Services

**Terminal 1 - API:**
```bash
cd PremiumMatcher/PremiumMatcher.Api
source ../.env  # Load environment variables
dotnet run
```

**Terminal 2 - Web Frontend:**
```bash
cd PremiumMatcher/PremiumMatcher/PremiumMatcher.Web
dotnet run
```

### Step 5: Access Application

Open your browser to: **http://localhost:5142**

---

## Option 2: Manual Deployment

### Step 1: Setup Database

```bash
# Create PostgreSQL database
createdb ethiopian_hdss

# Or using psql:
psql -U postgres -c "CREATE DATABASE ethiopian_hdss;"
```

### Step 2: Apply Migrations

```bash
# Navigate to project root
cd PIRL_RecordLinkageSoftware

# Apply migrations in order
psql -U postgres -d ethiopian_hdss -f supabase/migrations/0001_enable_extensions.sql
psql -U postgres -d ethiopian_hdss -f supabase/migrations/0002_schema.sql
psql -U postgres -d ethiopian_hdss -f supabase/migrations/0003_functions.sql  # Fixed version
psql -U postgres -d ethiopian_hdss -f supabase/migrations/0004_ethiopian_adaptations.sql
```

### Step 3: Load Sample Data

```bash
psql -U postgres -d ethiopian_hdss -f FakeData/ethiopian_sample_data.sql
```

### Step 4: Configure Environment

```bash
# Create .env file
cat > .env <<EOF
SUPABASE_DB_URL=postgresql://postgres:yourpassword@localhost:5432/ethiopian_hdss
EOF

# Load environment
source .env
```

### Step 5: Build and Run

```bash
# Build API
cd PremiumMatcher/PremiumMatcher.Api
dotnet build
dotnet run

# In another terminal, build Web
cd PremiumMatcher/PremiumMatcher/PremiumMatcher.Web
dotnet build
dotnet run
```

---

## Testing the System

### Test 1: Basic Search

1. Open http://localhost:5142/match
2. Enter search criteria:
   - **First Name:** Abebe
   - **Father's Name:** Bekele
   - **Gender:** Male
   - **Birth Year:** 1985
3. Check "Use First Name", "Use Father's Name", "Use Gender", "Use Birth Year"
4. Click **"Search"** (or **"ፈልግ"** in Amharic)

**Expected Result:** Should find record ETH-AM-001 with high match score (>0.8)

### Test 2: Fuzzy Matching

1. Enter search criteria:
   - **First Name:** Ababa (deliberate misspelling)
   - **Father's Name:** Bekele
   - **Birth Year:** 1984 (off by 1 year)
2. Click **"Search"**

**Expected Result:** Should still find ETH-AM-001 and ETH-AM-006 with good scores (>0.6)

### Test 3: Location-Based Search

1. Enter search criteria:
   - **Kebele:** Azezo
   - **Gott:** Maraki
2. Check "Use Kebele"
3. Click **"Search"**

**Expected Result:** Should find all individuals from Azezo/Maraki

### Test 4: Assign Match

1. Search for "Abebe"
2. Select a candidate
3. Fill in match assignment:
   - **Health Facility:** Gondar Health Center
   - **EMR Number:** EMR-12345
   - **Record Number:** REC-001
4. Click **"Assign Match"** (or **"ግጥሚያ ይመድቡ"** in Amharic)

**Expected Result:** Success message with match ID

---

## Verify Installation

### Check Database

```bash
psql -U postgres -d ethiopian_hdss -c "SELECT COUNT(*) FROM dss_individuals;"
```

**Expected:** At least 25 records (if sample data loaded)

### Check Search Function

```bash
psql -U postgres -d ethiopian_hdss -c "
SELECT dss_id, score, first_name, father_name_latin, kebele
FROM search_candidates(
    'Abebe', null, null, null, null, null, 'M',
    null, null, '1985', null, null,
    true, false, false, false, false, false, true,
    false, false, true, false, false
)
LIMIT 5;"
```

**Expected:** Should return records with scores between 0 and 1

### Check API

```bash
curl http://localhost:5151/openapi/v1.json
```

**Expected:** OpenAPI specification JSON

---

## Ethiopian Calendar Testing

The system includes Ethiopian calendar (Ge'ez calendar) support:

### Convert Ethiopian to Gregorian

```csharp
// Ethiopian date: 15 Ginbot 2017 (15th day, 9th month, 2017)
var gregorianDate = EthiopianCalendar.ToGregorian(2017, 9, 15);
// Result: May 23, 2025

Console.WriteLine($"Ethiopian: 15 Ginbot 2017");
Console.WriteLine($"Gregorian: {gregorianDate:d MMMM yyyy}");
```

### Convert Gregorian to Ethiopian

```csharp
var ethiopian = EthiopianCalendar.ToEthiopian(new DateTime(2025, 5, 23));
// Result: (year: 2017, month: 9, day: 15)

Console.WriteLine($"Gregorian: May 23, 2025");
Console.WriteLine($"Ethiopian: {ethiopian.day} {EthiopianCalendar.GetMonthName(ethiopian.month)} {ethiopian.year}");
// Output: 15 Ginbot 2017
```

---

## Language Switching

The UI supports multiple languages:

### English
- Default language
- Fields: First Name, Father's Name, Kebele, etc.

### Amharic (አማርኛ)
- Resource file: `Match.am.resx`
- Fields: የመጀመሪያ ስም, የአባት ስም, ቀበሌ, etc.

### Add More Languages

Create additional `.resx` files:
- `Match.om.resx` - Oromo (Afaan Oromoo)
- `Match.ti.resx` - Tigrinya (ትግርኛ)

---

## Common Issues & Solutions

### Issue 1: "Database connection failed"

**Solution:**
```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Start if not running
sudo systemctl start postgresql

# Check connection
psql -U postgres -c "\l"
```

### Issue 2: "Migration already exists"

**Solution:**
This is normal. Migrations are idempotent and can be run multiple times safely.

### Issue 3: "dotnet: command not found"

**Solution:**
```bash
# Add .NET to PATH
export PATH="$PATH:$HOME/.dotnet"

# Verify
dotnet --version
```

### Issue 4: "Port 5151 already in use"

**Solution:**
```bash
# Find process using port
lsof -i :5151

# Kill process
kill -9 <PID>

# Or change port in launchSettings.json
```

### Issue 5: "Search returns no results"

**Solution:**
```bash
# Verify sample data loaded
psql -U postgres -d ethiopian_hdss -c "SELECT COUNT(*) FROM dss_individuals WHERE dss_id LIKE 'ETH-%';"

# Should return 25 if sample data loaded

# If not, reload:
psql -U postgres -d ethiopian_hdss -f FakeData/ethiopian_sample_data.sql
```

---

## Sample Queries for Testing

### Find all Amhara region individuals

```sql
SELECT dss_id, first_name_latin, father_name_latin, kebele, gott
FROM dss_individuals
WHERE region = 'Amhara'
ORDER BY kebele, gott;
```

### Search with Ethiopian calendar

```sql
SELECT dss_id, first_name_latin, birth_year, birth_year_ethiopian, calendar_type
FROM dss_individuals
WHERE calendar_type = 'ethiopian'
ORDER BY birth_year_ethiopian DESC;
```

### Find potential duplicates

```sql
SELECT * FROM potential_duplicates
ORDER BY name_similarity DESC
LIMIT 10;
```

### Match quality metrics

```sql
SELECT
    kebele,
    COUNT(*) as total_searches,
    AVG(score) as avg_score,
    COUNT(*) FILTER (WHERE score >= 0.8) as high_quality_matches
FROM matches
GROUP BY kebele
ORDER BY total_searches DESC;
```

---

## Production Deployment Checklist

Before deploying to production:

- [ ] **Security**
  - [ ] Change default PostgreSQL password
  - [ ] Configure CORS to specific origins (not AllowAnyOrigin)
  - [ ] Enable HTTPS
  - [ ] Add authentication/authorization
  - [ ] Review audit logging

- [ ] **Database**
  - [ ] Backup existing data
  - [ ] Set up automated backups
  - [ ] Configure connection pooling
  - [ ] Optimize indexes for your data volume

- [ ] **Application**
  - [ ] Set environment to Production
  - [ ] Configure logging (e.g., Serilog, Application Insights)
  - [ ] Add health check endpoints
  - [ ] Configure rate limiting

- [ ] **Monitoring**
  - [ ] Set up application monitoring
  - [ ] Configure database monitoring
  - [ ] Set up alerts for errors

- [ ] **Documentation**
  - [ ] Train staff on system usage
  - [ ] Translate UI to local languages
  - [ ] Create user manual in Amharic

---

## Next Steps

1. ✅ **Test thoroughly** with your actual HDSS data
2. 📚 **Review** `ETHIOPIAN_HDSS_ADAPTATION_GUIDE.md` for detailed customization
3. 🎓 **Train** data managers using the 3-day curriculum
4. 🔧 **Customize** scoring weights for your specific context
5. 🌍 **Integrate** with Ethiopian HMIS/DHIS2 if needed
6. 📱 **Deploy** as PWA for offline capability

---

## Support

- **Documentation:** See `ETHIOPIAN_HDSS_ADAPTATION_GUIDE.md`
- **Issues:** Create GitHub issue
- **EPHI:** ephi@ethionet.et
- **Community:** Ethiopian Public Health Data Science Community

---

## What's Fixed in This Version

✅ **Critical Bugs Fixed:**
1. Birth date matching now works correctly (was checking gender field)
2. Match scores now range 0.0-1.0 (was 0-1.55)

✅ **Ethiopian Enhancements Added:**
1. Kebele/Woreda/Region administrative divisions
2. Ethiopian calendar support (Ge'ez calendar)
3. Amharic language resources
4. Ethiopian health system IDs (EMR, SmartCare, ART, etc.)
5. Sample Ethiopian HDSS data (25 records)

---

**Ready to match records!** 🎉

If you encounter any issues, check the troubleshooting section or create a GitHub issue.
