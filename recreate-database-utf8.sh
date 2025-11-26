#!/bin/bash
# Recreate Database with UTF-8 Encoding
# This script drops and recreates the database with proper UTF-8 encoding for Amharic text

echo "=================================="
echo "Database Recreation Script (UTF-8)"
echo "=================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Database connection parameters
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="ethiopian_hdss"
DB_USER="postgres"

echo -e "${YELLOW}⚠ WARNING: This will DELETE all existing data in the database!${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

# Prompt for password
echo ""
read -sp "Enter database password: " DB_PASSWORD
echo ""
export PGPASSWORD=$DB_PASSWORD

# Test connection
echo ""
echo "Step 1: Testing connection..."
echo "=================================="
if ! psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c '\q' 2>/dev/null; then
    echo -e "${RED}✗ Cannot connect to PostgreSQL${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Connected successfully${NC}"

# Terminate existing connections to the database
echo ""
echo "Step 2: Terminating existing connections..."
echo "=================================="
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '${DB_NAME}' AND pid <> pg_backend_pid();" 2>/dev/null
echo -e "${GREEN}✓ Existing connections terminated${NC}"

# Drop existing database
echo ""
echo "Step 3: Dropping existing database..."
echo "=================================="
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "DROP DATABASE IF EXISTS ${DB_NAME};" 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Old database dropped${NC}"
else
    echo -e "${RED}✗ Failed to drop database${NC}"
    exit 1
fi

# Create database with UTF-8 encoding
echo ""
echo "Step 4: Creating database with UTF-8 encoding..."
echo "=================================="
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE ${DB_NAME} WITH ENCODING='UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE=template0;" 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database created with UTF-8 encoding${NC}"
else
    echo -e "${YELLOW}⚠ UTF-8 with locale failed, trying C locale...${NC}"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE ${DB_NAME} WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0;" 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Database created with UTF-8 encoding (C locale)${NC}"
    else
        echo -e "${RED}✗ Failed to create database${NC}"
        exit 1
    fi
fi

# Verify encoding
echo ""
echo "Step 5: Verifying database encoding..."
echo "=================================="
ENCODING=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SHOW server_encoding;" | tr -d ' ')
echo "Database encoding: $ENCODING"
if [ "$ENCODING" = "UTF8" ]; then
    echo -e "${GREEN}✓ UTF-8 encoding confirmed${NC}"
else
    echo -e "${RED}✗ Wrong encoding: $ENCODING${NC}"
    exit 1
fi

# Apply migrations
echo ""
echo "Step 6: Applying migrations..."
echo "=================================="

echo ""
echo "Migration 1: Extensions..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f supabase/migrations/0001_enable_extensions.sql
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Extensions enabled${NC}"
else
    echo -e "${RED}✗ Extensions failed${NC}"
    exit 1
fi

echo ""
echo "Migration 2: Schema..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f supabase/migrations/0002_schema.sql
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Schema created${NC}"
else
    echo -e "${RED}✗ Schema failed${NC}"
    exit 1
fi

echo ""
echo "Migration 3: Functions..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f supabase/migrations/0003_functions.sql
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Functions created${NC}"
else
    echo -e "${RED}✗ Functions failed${NC}"
    exit 1
fi

echo ""
echo "Migration 4: Ethiopian adaptations..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f supabase/migrations/0004_ethiopian_adaptations.sql 2>&1 | grep -v "NOTICE:"
if [ $? -eq 0 ] || [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}✓ Ethiopian adaptations applied${NC}"
else
    echo -e "${RED}✗ Ethiopian adaptations failed${NC}"
    exit 1
fi

# Load sample data
echo ""
echo "Step 7: Loading sample data..."
echo "=================================="
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f FakeData/ethiopian_sample_data.sql 2>&1 | grep -v "NOTICE:"
if [ $? -eq 0 ] || [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}✓ Sample data loaded${NC}"
else
    echo -e "${RED}✗ Sample data failed${NC}"
    exit 1
fi

# Verification
echo ""
echo "Step 8: Verification..."
echo "=================================="

# Count records
TOTAL_COUNT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM dss_individuals;" 2>/dev/null | tr -d ' ')
ETH_COUNT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM dss_individuals WHERE dss_id LIKE 'ETH-%';" 2>/dev/null | tr -d ' ')

echo "Total records: $TOTAL_COUNT"
echo "Ethiopian records: $ETH_COUNT"

if [ "$ETH_COUNT" -eq 25 ]; then
    echo -e "${GREEN}✓ All 25 Ethiopian sample records loaded!${NC}"
else
    echo -e "${RED}✗ Expected 25 records, got $ETH_COUNT${NC}"
fi

# Show sample with Amharic names
echo ""
echo "Sample records with Amharic names:"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT dss_id, first_name, father_name_amharic, region FROM dss_individuals WHERE dss_id LIKE 'ETH-%' LIMIT 5;"

# Test search function
echo ""
echo "Testing search_candidates function:"
TEST_RESULT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM search_candidates('Abebe', null, null, null, null, null, 'M', null, null, '1985', null, null, true, false, false, false, false, false, true, false, false, true, false, false);" 2>&1 | tr -d ' ')

if [[ $TEST_RESULT =~ ^[0-9]+$ ]]; then
    echo -e "${GREEN}✓ Search function working! Found $TEST_RESULT matches for 'Abebe'${NC}"
else
    echo -e "${RED}✗ Search function error: $TEST_RESULT${NC}"
    exit 1
fi

# Update connection string in config
cat > PremiumMatcher/PremiumMatcher.Api/appsettings.Production.json <<EOF
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Supabase": {
    "ConnectionString": "postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
  }
}
EOF

# Save to .env
cat > .env <<EOF
# Ethiopian HDSS Database Connection (UTF-8)
SUPABASE_DB_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
EOF

echo ""
echo "=================================="
echo -e "${GREEN}✓ Database setup complete!${NC}"
echo "=================================="
echo ""
echo "Next Steps:"
echo "==========="
echo ""
echo "1. Start the API (Terminal 1):"
echo "   cd PremiumMatcher/PremiumMatcher.Api"
echo "   export SUPABASE_DB_URL='postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}'"
echo "   dotnet run"
echo ""
echo "2. Start the Web frontend (Terminal 2):"
echo "   cd PremiumMatcher/PremiumMatcher/PremiumMatcher.Web"
echo "   dotnet run"
echo ""
echo "3. Open browser: http://localhost:5142"
echo ""
echo -e "${GREEN}✓ Configuration saved to .env and appsettings.Production.json${NC}"
echo ""
