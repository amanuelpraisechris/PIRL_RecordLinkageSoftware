#!/bin/bash
# Quick Fix Script for Database Issues
# This script re-applies the corrected migrations and loads sample data

echo "=================================="
echo "Database Fix Script"
echo "=================================="
echo ""

# Database connection parameters
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="ethiopian_hdss"
DB_USER="postgres"

# Prompt for password
read -sp "Enter database password: " DB_PASSWORD
echo ""
export PGPASSWORD=$DB_PASSWORD

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "Step 1: Re-applying corrected function migration..."
echo "=================================="
if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f supabase/migrations/0003_functions.sql; then
    echo -e "${GREEN}✓ Function migration applied successfully${NC}"
else
    echo -e "${RED}✗ Function migration failed${NC}"
    exit 1
fi

echo ""
echo "Step 2: Re-applying Ethiopian adaptations..."
echo "=================================="
if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f supabase/migrations/0004_ethiopian_adaptations.sql; then
    echo -e "${GREEN}✓ Ethiopian adaptations applied${NC}"
else
    echo -e "${RED}✗ Ethiopian adaptations failed${NC}"
    exit 1
fi

echo ""
echo "Step 3: Loading sample data..."
echo "=================================="
if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f FakeData/ethiopian_sample_data.sql; then
    echo -e "${GREEN}✓ Sample data loaded${NC}"
else
    echo -e "${RED}✗ Sample data load failed${NC}"
    exit 1
fi

echo ""
echo "Step 4: Verification..."
echo "=================================="

# Count records
TOTAL_COUNT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM dss_individuals;" | tr -d ' ')
ETH_COUNT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM dss_individuals WHERE dss_id LIKE 'ETH-%';" | tr -d ' ')

echo "Total records: $TOTAL_COUNT"
echo "Ethiopian records: $ETH_COUNT"

# Test search function
echo ""
echo "Testing search_candidates function:"
TEST_RESULT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM search_candidates('Abebe', null, null, null, null, null, 'M', null, null, '1985', null, null, true, false, false, false, false, false, true, false, false, true, false, false);" 2>&1)

if [[ $TEST_RESULT =~ ^[0-9]+$ ]]; then
    echo -e "${GREEN}✓ Search function working! Found $TEST_RESULT matches for 'Abebe'${NC}"
else
    echo -e "${RED}✗ Search function error:${NC}"
    echo "$TEST_RESULT"
    exit 1
fi

echo ""
echo "=================================="
echo -e "${GREEN}✓ Database fixed successfully!${NC}"
echo "=================================="
echo ""
echo "You can now start the application:"
echo ""
echo "1. Terminal 1 (API):"
echo "   cd PremiumMatcher/PremiumMatcher.Api"
echo "   export SUPABASE_DB_URL='postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}'"
echo "   dotnet run"
echo ""
echo "2. Terminal 2 (Web):"
echo "   cd PremiumMatcher/PremiumMatcher/PremiumMatcher.Web"
echo "   dotnet run"
echo ""
echo "3. Open browser: http://localhost:5142"
echo ""
