#!/bin/bash
# Quick API Test Script
# This script tests if the API is responding correctly

echo "=================================="
echo "Ethiopian HDSS API Test"
echo "=================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test if API is running
echo "Step 1: Testing if API is accessible..."
echo "=================================="
API_URL="http://localhost:5000/api/search"

# Simple connectivity test
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ API port 5000 is accessible${NC}"
else
    echo -e "${RED}✗ Cannot reach API on port 5000${NC}"
    echo ""
    echo "Make sure the API is running:"
    echo "  bash PremiumMatcher/PremiumMatcher.Api/start-api.sh"
    echo ""
    exit 1
fi

# Test search endpoint
echo ""
echo "Step 2: Testing search endpoint..."
echo "=================================="
echo "Searching for 'Abebe' (Male, born 1985)..."
echo ""

RESPONSE=$(curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Abebe",
    "middleName": null,
    "lastName": null,
    "gender": "M",
    "birthDay": null,
    "birthMonth": null,
    "birthYear": "1985",
    "village": null,
    "subvillage": null,
    "useFirstName": true,
    "useMiddleName": false,
    "useLastName": false,
    "useGender": true,
    "useBirthDay": false,
    "useBirthMonth": false,
    "useBirthYear": true,
    "useVillage": false,
    "useSubvillage": false
  }' 2>&1)

# Check if response is valid JSON
if echo "$RESPONSE" | grep -q "candidates"; then
    echo -e "${GREEN}✓ API returned valid response${NC}"
    echo ""

    # Count candidates
    CANDIDATE_COUNT=$(echo "$RESPONSE" | grep -o '"dssId"' | wc -l)

    if [ "$CANDIDATE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✓ Found $CANDIDATE_COUNT candidate(s)${NC}"
        echo ""
        echo "Sample response:"
        echo "$RESPONSE" | head -20
        echo "..."
    else
        echo -e "${YELLOW}⚠ API responded but found 0 candidates${NC}"
        echo ""
        echo "This might mean:"
        echo "  1. Sample data is not loaded in database"
        echo "  2. Search function not working correctly"
        echo ""
        echo "Try running: bash recreate-database-utf8.sh"
    fi
else
    echo -e "${RED}✗ API returned error or invalid response${NC}"
    echo ""
    echo "Response:"
    echo "$RESPONSE"
    echo ""
    echo "Common issues:"
    echo "  1. Database not configured (check SUPABASE_DB_URL)"
    echo "  2. Database connection failed"
    echo "  3. Search function not created in database"
    echo ""
    echo "Try running: bash diagnose-database.sh"
    exit 1
fi

# Test database directly
echo ""
echo "Step 3: Testing database connection..."
echo "=================================="

if command -v psql &> /dev/null; then
    echo "Checking database record count..."

    # Load password from .env if available
    if [ -f ".env" ]; then
        source .env
        export PGPASSWORD=$(echo $SUPABASE_DB_URL | sed -n 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/p')
    fi

    RECORD_COUNT=$(PGPASSWORD="${PGPASSWORD:-CENamantracy@0912}" psql -h localhost -U postgres -d ethiopian_hdss -t -c "SELECT COUNT(*) FROM dss_individuals;" 2>/dev/null | tr -d ' ')

    if [[ $RECORD_COUNT =~ ^[0-9]+$ ]]; then
        if [ "$RECORD_COUNT" -eq 25 ]; then
            echo -e "${GREEN}✓ Database has $RECORD_COUNT records (expected 25)${NC}"
        elif [ "$RECORD_COUNT" -gt 0 ]; then
            echo -e "${YELLOW}⚠ Database has $RECORD_COUNT records (expected 25)${NC}"
        else
            echo -e "${RED}✗ Database has 0 records${NC}"
            echo "  Run: bash recreate-database-utf8.sh"
        fi
    else
        echo -e "${YELLOW}⚠ Could not check database (psql connection issue)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ psql not available, skipping database check${NC}"
fi

echo ""
echo "=================================="
echo "Test Summary"
echo "=================================="
echo ""

if [ "$CANDIDATE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓✓✓ API is working correctly! ✓✓✓${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Open browser to: http://localhost:5142"
    echo "  2. Try searching for 'Abebe' in the web interface"
    echo "  3. See VERIFICATION_GUIDE.md for detailed testing"
    echo ""
else
    echo -e "${YELLOW}⚠⚠⚠ API is running but has issues ⚠⚠⚠${NC}"
    echo ""
    echo "Recommended actions:"
    echo "  1. Run: bash diagnose-database.sh"
    echo "  2. If needed: bash recreate-database-utf8.sh"
    echo "  3. Restart API: bash PremiumMatcher/PremiumMatcher.Api/start-api.sh"
    echo ""
fi
