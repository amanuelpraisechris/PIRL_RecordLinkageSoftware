#!/bin/bash
# Start API with proper environment variables

echo "Starting Ethiopian HDSS API..."
echo ""

# Set database connection from .env if it exists
if [ -f "../../.env" ]; then
    source ../../.env
    echo "✓ Loaded database connection from .env"
elif [ -f ".env" ]; then
    source .env
    echo "✓ Loaded database connection from .env"
else
    echo "⚠ Warning: .env file not found. Using default connection string..."
    export SUPABASE_DB_URL='postgresql://postgres:CENamantracy@0912@localhost:5432/ethiopian_hdss'
fi

echo "Database: $SUPABASE_DB_URL"
echo ""
echo "Starting API on http://localhost:5000..."
echo ""

dotnet run
