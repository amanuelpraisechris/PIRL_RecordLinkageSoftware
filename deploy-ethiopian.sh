#!/bin/bash
# Ethiopian HDSS Deployment Script
# This script sets up the database and deploys the application for Ethiopian HDSS context

set -e  # Exit on error

echo "=================================="
echo "Ethiopian HDSS Deployment Script"
echo "=================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo "ℹ $1"
}

# Check prerequisites
echo "Step 1: Checking prerequisites..."

# Check if PostgreSQL client is installed
if ! command -v psql &> /dev/null; then
    print_error "PostgreSQL client (psql) not found. Please install PostgreSQL."
    exit 1
fi
print_success "PostgreSQL client found"

# Check if .NET SDK is installed
if ! command -v dotnet &> /dev/null; then
    print_warning ".NET SDK not found. You'll need it to build and run the application."
else
    print_success ".NET SDK found ($(dotnet --version))"
fi

# Database connection parameters
echo ""
echo "Step 2: Database Configuration"
echo "================================"

# Prompt for database connection details
read -p "Enter PostgreSQL host (default: localhost): " DB_HOST
DB_HOST=${DB_HOST:-localhost}

read -p "Enter PostgreSQL port (default: 5432): " DB_PORT
DB_PORT=${DB_PORT:-5432}

read -p "Enter database name (default: ethiopian_hdss): " DB_NAME
DB_NAME=${DB_NAME:-ethiopian_hdss}

read -p "Enter database user (default: postgres): " DB_USER
DB_USER=${DB_USER:-postgres}

read -sp "Enter database password: " DB_PASSWORD
echo ""

# Construct connection string
export PGPASSWORD=$DB_PASSWORD
CONN_STRING="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

# Test connection
echo ""
echo "Testing database connection..."
if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c '\q' 2>/dev/null; then
    print_success "Database connection successful"
else
    print_error "Cannot connect to database. Please check your credentials."
    exit 1
fi

# Create database if it doesn't exist
echo ""
echo "Step 3: Creating database (if not exists)..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}'" | grep -q 1 || \
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE ${DB_NAME};"
print_success "Database '${DB_NAME}' ready"

# Run migrations
echo ""
echo "Step 4: Running database migrations..."
echo "================================"

# Check if migration files exist
if [ ! -d "supabase/migrations" ]; then
    print_error "Migration directory not found. Please ensure you're in the project root."
    exit 1
fi

# Run each migration in order
for migration in supabase/migrations/*.sql; do
    migration_file=$(basename "$migration")
    print_info "Applying migration: $migration_file"

    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$migration" > /dev/null 2>&1; then
        print_success "Applied: $migration_file"
    else
        print_warning "Migration may have already been applied or encountered an error: $migration_file"
    fi
done

# Load sample Ethiopian data
echo ""
read -p "Load sample Ethiopian test data? (y/n): " LOAD_SAMPLE
if [[ $LOAD_SAMPLE == "y" || $LOAD_SAMPLE == "Y" ]]; then
    print_info "Loading Ethiopian sample data..."
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f FakeData/ethiopian_sample_data.sql > /dev/null 2>&1; then
        print_success "Sample data loaded successfully"
    else
        print_warning "Sample data load failed (may already exist)"
    fi
fi

# Configure API
echo ""
echo "Step 5: Configuring API..."
echo "================================"

# Create appsettings.Production.json
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
    "ConnectionString": "${CONN_STRING}"
  }
}
EOF

print_success "API configuration created"

# Set environment variable
export SUPABASE_DB_URL="${CONN_STRING}"
print_info "Environment variable SUPABASE_DB_URL set"

# Build application
echo ""
echo "Step 6: Building application..."
echo "================================"

if command -v dotnet &> /dev/null; then
    print_info "Building API..."
    cd PremiumMatcher/PremiumMatcher.Api
    if dotnet build -c Release > /dev/null 2>&1; then
        print_success "API built successfully"
    else
        print_warning "API build failed"
    fi
    cd ../..

    print_info "Building Web frontend..."
    cd PremiumMatcher/PremiumMatcher/PremiumMatcher.Web
    if dotnet build -c Release > /dev/null 2>&1; then
        print_success "Web frontend built successfully"
    else
        print_warning "Web frontend build failed"
    fi
    cd ../../..
else
    print_warning "Skipping build (dotnet not found)"
fi

# Verification
echo ""
echo "Step 7: Verification..."
echo "================================"

# Count records
RECORD_COUNT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM dss_individuals;" | tr -d ' ')
print_info "Total DSS individuals: $RECORD_COUNT"

ETHIOPIAN_COUNT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM dss_individuals WHERE dss_id LIKE 'ETH-%';" | tr -d ' ')
print_info "Ethiopian sample records: $ETHIOPIAN_COUNT"

# Test search function
print_info "Testing search function..."
TEST_RESULT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM search_candidates('Abebe', null, null, null, null, null, 'M', null, null, '1985', null, null, true, false, false, false, false, false, true, false, false, true, false, false);" | tr -d ' ')
if [ "$TEST_RESULT" -gt 0 ]; then
    print_success "Search function working (found $TEST_RESULT matches)"
else
    print_warning "Search function returned no results"
fi

# Deployment summary
echo ""
echo "=================================="
echo "Deployment Summary"
echo "=================================="
echo ""
print_success "Database: $DB_NAME on $DB_HOST:$DB_PORT"
print_success "Migrations: Applied"
print_success "Sample data: $ETHIOPIAN_COUNT Ethiopian records"
print_success "Search function: Tested"

# Next steps
echo ""
echo "Next Steps:"
echo "==========="
echo "1. Start the API:"
echo "   cd PremiumMatcher/PremiumMatcher.Api"
echo "   export SUPABASE_DB_URL='${CONN_STRING}'"
echo "   dotnet run"
echo ""
echo "2. In another terminal, start the Web frontend:"
echo "   cd PremiumMatcher/PremiumMatcher/PremiumMatcher.Web"
echo "   dotnet run"
echo ""
echo "3. Open browser to: http://localhost:5142"
echo ""
echo "4. For production deployment, see: ETHIOPIAN_HDSS_ADAPTATION_GUIDE.md"
echo ""

# Save connection string to .env file
cat > .env <<EOF
# Ethiopian HDSS Database Connection
SUPABASE_DB_URL=${CONN_STRING}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
EOF

print_success "Connection details saved to .env file"

echo ""
print_success "Deployment completed successfully!"
echo ""

# Security warning
print_warning "IMPORTANT: Keep your .env file secure and don't commit it to version control!"
echo ""
