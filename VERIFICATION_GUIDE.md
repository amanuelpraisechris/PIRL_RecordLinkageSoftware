# Ethiopian HDSS Software Verification Guide

This guide will help you verify that the software is working correctly.

## Prerequisites Checklist

Before testing, make sure:

- [ ] Database recreated with UTF-8 encoding (ran `recreate-database-utf8.sh`)
- [ ] 25 Ethiopian sample records loaded (verified in database script output)
- [ ] API is running (Terminal 1 shows "Now listening on: http://localhost:5000")
- [ ] Web frontend is running (Terminal 2 shows "Now listening on: http://localhost:5142")

## Step 1: Test API Directly

Open Git Bash and test the API endpoint:

```bash
# Test the search endpoint
curl -X POST http://localhost:5000/api/search \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Abebe",
    "useFirstName": true,
    "gender": "M",
    "useGender": true,
    "birthYear": "1985",
    "useBirthYear": true
  }'
```

**Expected Result:** You should see JSON data with candidates like:
```json
{
  "candidates": [
    {
      "dssId": "ETH-001",
      "firstName": "Abebe",
      "score": 0.85,
      ...
    }
  ]
}
```

## Step 2: Test Web Interface

### 2.1 Open Browser
1. Open your web browser (Chrome, Firefox, or Edge)
2. Navigate to: `http://localhost:5142`

### 2.2 What You Should See

**Homepage:**
- Title: "PIRL Record Linkage" or "Ethiopian HDSS Record Linkage"
- Navigation menu
- Search form with fields:
  - First Name
  - Middle Name (Father's Name)
  - Last Name (Grandfather's Name)
  - Gender dropdown
  - Birth Year
  - Checkboxes to enable/disable each field

### 2.3 Test Basic Search

1. **Simple Search Test:**
   - Enter "Abebe" in First Name field
   - Check the "Use First Name" checkbox
   - Click "Search" button

2. **Expected Results:**
   - Should see a table with matching candidates
   - Should show DSS ID (like "ETH-001")
   - Should show match score (0.0 to 1.0)
   - Should show person details (name, gender, birth year)

### 2.4 Test Ethiopian Sample Data

Try these searches to verify Ethiopian data is loaded:

**Test 1: Search for "Abebe"**
```
First Name: Abebe
Gender: Male
Expected: Should find 1 record from Amhara region
```

**Test 2: Search for "Fatuma"**
```
First Name: Fatuma
Gender: Female
Expected: Should find 1 record from Oromia region
```

**Test 3: Search for "Tigist"**
```
First Name: Tigist
Gender: Female
Expected: Should find 1 record from Addis Ababa
```

**Test 4: Search by Year**
```
First Name: (leave blank)
Birth Year: 1990
Use Birth Year: ✓
Expected: Should find multiple records born around 1990
```

## Step 3: Browser Console Check

1. Press `F12` to open Developer Tools
2. Go to "Console" tab
3. Reload the page (`F5`)

**Expected:**
- No red error messages
- May see some informational messages in blue/gray

**Red Flags:**
- "Failed to fetch" - API is not running
- "404 Not Found" - API endpoint not configured correctly
- "CORS error" - CORS configuration issue

## Step 4: Network Tab Check

1. In Developer Tools (F12), go to "Network" tab
2. Perform a search
3. Look for request to `/api/search`

**Expected:**
- Request URL: `http://localhost:5000/api/search`
- Status: `200 OK`
- Response Type: JSON with candidate data

## Troubleshooting

### Issue: Page Won't Load (http://localhost:5142)

**Symptoms:** Browser shows "Can't reach this page" or "Connection refused"

**Solution:**
```bash
# Check if Web frontend is running
# In Git Bash, you should see Terminal 2 with:
# "Now listening on: http://localhost:5142"

# If not running, start it:
cd ~/PIRL_RecordLinkageSoftware
bash PremiumMatcher/PremiumMatcher/PremiumMatcher.Web/start-web.sh
```

### Issue: Page Loads but Search Returns No Results

**Symptoms:** Search button works but always returns 0 results

**Possible Causes:**
1. API not running
2. Database has no data
3. API can't connect to database

**Solution:**
```bash
# 1. Check API is running (Terminal 1)
# Should show "Now listening on: http://localhost:5000"

# 2. Test API directly with curl (see Step 1 above)

# 3. Verify database has data:
psql -h localhost -U postgres -d ethiopian_hdss -c "SELECT COUNT(*) FROM dss_individuals;"
# Should show: 25
```

### Issue: Search Returns "Database not configured" Error

**Symptoms:** API returns 500 error with "Database not configured"

**Solution:**
```bash
# Stop the API (Ctrl+C in Terminal 1)

# Make sure .env file exists and has connection string:
cat .env

# Restart API:
bash PremiumMatcher/PremiumMatcher.Api/start-api.sh

# Should see: "✓ Loaded database connection from .env"
```

### Issue: CORS Error in Browser Console

**Symptoms:** Console shows "blocked by CORS policy"

**Solution:** This shouldn't happen with current setup, but if it does:
1. Make sure API is running on port 5000
2. Make sure Web is running on port 5142
3. Restart both services

### Issue: API Shows "Format of initialization string does not conform"

**Symptoms:** API crashes on startup with connection string error

**Solution:**
```bash
# Check .env file format:
cat .env

# Should look like:
# SUPABASE_DB_URL=postgresql://postgres:CENamantracy@0912@localhost:5432/ethiopian_hdss

# If missing, recreate database:
bash recreate-database-utf8.sh
```

## Success Indicators

✅ **Software is working correctly if:**

1. Web page loads at http://localhost:5142
2. Search form is visible and interactive
3. Searching for "Abebe" returns at least 1 result
4. Results show DSS ID, name, score, and other details
5. No errors in browser console
6. API responds to curl test with JSON data

## Next Steps After Verification

Once verified working:

1. **Try Advanced Searches:**
   - Search with multiple criteria
   - Test different name combinations
   - Try searches with birth date components

2. **Test Match Assignment:**
   - Select a candidate from search results
   - Try to assign/link them to a record
   - Check if assignment is saved

3. **Review Documentation:**
   - `ETHIOPIAN_HDSS_ADAPTATION_GUIDE.md` - Ethiopian-specific features
   - `SECURITY_GUIDE.md` - Security before production deployment
   - `WINDOWS_INSTALLATION.md` - Full installation reference

4. **Add Real Data:**
   - Once testing is complete with sample data
   - Import your actual HDSS data
   - Follow data import procedures in the adaptation guide

## Getting Help

If you encounter issues:

1. Check this troubleshooting guide first
2. Review error messages in:
   - Browser console (F12)
   - API terminal output (Terminal 1)
   - Web terminal output (Terminal 2)
3. Check database state:
   ```bash
   bash diagnose-database.sh
   ```

## Test Completion Checklist

After going through this guide, you should have verified:

- [ ] API is accessible and responding (curl test passed)
- [ ] Web interface loads in browser
- [ ] Search form is functional
- [ ] Sample Ethiopian data is searchable
- [ ] Search results display correctly
- [ ] No errors in browser console
- [ ] No errors in API/Web terminal output

---

**Status Check:** If all items are ✅, your Ethiopian HDSS Record Linkage Software is working correctly! 🎉
