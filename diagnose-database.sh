#!/bin/bash
# Database Diagnostic Script
# This script checks the database state and shows any errors

echo "=================================="
echo "Database Diagnostic Script"
echo "=================================="
echo ""

# Database connection parameters (from your deployment)
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
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "=================================="
echo "1. Checking Database Connection"
echo "=================================="
if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c '\q' 2>&1; then
    echo -e "${GREEN}✓ Connected to database${NC}"
else
    echo -e "${RED}✗ Cannot connect to database${NC}"
    exit 1
fi

echo ""
echo "=================================="
echo "2. Checking Extensions"
echo "=================================="
echo "Installed extensions:"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT extname, extversion FROM pg_extension ORDER BY extname;"

echo ""
echo "=================================="
echo "3. Checking Tables"
echo "=================================="
echo "Tables in public schema:"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\dt public.*"

echo ""
echo "Table record counts:"
for table in dss_individuals matches assignment_history audit_log quality_metrics; do
    COUNT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM $table;" 2>&1 | tr -d ' ')
    if [[ $COUNT =~ ^[0-9]+$ ]]; then
        echo -e "  $table: ${BLUE}$COUNT${NC} records"
    else
        echo -e "  $table: ${RED}ERROR - Table may not exist${NC}"
    fi
done

echo ""
echo "=================================="
echo "4. Checking Functions"
echo "=================================="
echo "search_candidates function:"
FUNC_EXISTS=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM pg_proc WHERE proname = 'search_candidates';" | tr -d ' ')
if [ "$FUNC_EXISTS" -gt 0 ]; then
    echo -e "${GREEN}✓ Function exists${NC}"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\df search_candidates"
else
    echo -e "${RED}✗ Function does not exist${NC}"
fi

echo ""
echo "=================================="
echo "5. Testing Migrations (with errors shown)"
echo "=================================="

echo ""
echo -e "${BLUE}Testing migration 0001_enable_extensions.sql:${NC}"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f supabase/migrations/0001_enable_extensions.sql

echo ""
echo -e "${BLUE}Testing migration 0002_schema.sql:${NC}"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f supabase/migrations/0002_schema.sql 2>&1 | head -50

echo ""
echo -e "${BLUE}Testing migration 0003_functions.sql:${NC}"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f supabase/migrations/0003_functions.sql 2>&1 | head -50

echo ""
echo -e "${BLUE}Testing migration 0004_ethiopian_adaptations.sql:${NC}"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f supabase/migrations/0004_ethiopian_adaptations.sql 2>&1 | head -50

echo ""
echo "=================================="
echo "6. Attempting to Load Sample Data"
echo "=================================="
echo -e "${BLUE}Loading FakeData/ethiopian_sample_data.sql:${NC}"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f FakeData/ethiopian_sample_data.sql 2>&1 | head -50

echo ""
echo "=================================="
echo "7. Final Verification"
echo "=================================="

# Recheck counts
TOTAL_COUNT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM dss_individuals;" 2>/dev/null | tr -d ' ')
ETH_COUNT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM dss_individuals WHERE dss_id LIKE 'ETH-%';" 2>/dev/null | tr -d ' ')

echo -e "Total records: ${BLUE}$TOTAL_COUNT${NC}"
echo -e "Ethiopian records: ${BLUE}$ETH_COUNT${NC}"

# Test search function
echo ""
echo "Testing search_candidates function:"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) FROM search_candidates('Abebe', null, null, null, null, null, 'M', null, null, '1985', null, null, true, false, false, false, false, false, true, false, false, true, false, false);"

echo ""
echo "=================================="
echo "Diagnostic Complete"
echo "=================================="
