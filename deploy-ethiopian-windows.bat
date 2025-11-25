@echo off
REM Ethiopian HDSS Deployment Script for Windows
REM Run this script from the project root directory

echo ==================================
echo Ethiopian HDSS Deployment (Windows)
echo ==================================
echo.

REM Check if PostgreSQL is installed
where psql >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] PostgreSQL not found!
    echo.
    echo Please install PostgreSQL:
    echo 1. Go to: https://www.postgresql.org/download/windows/
    echo 2. Download and install PostgreSQL 16.x
    echo 3. Restart this script
    echo.
    pause
    exit /b 1
)
echo [OK] PostgreSQL found

REM Check if .NET SDK is installed
where dotnet >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] .NET SDK not found!
    echo.
    echo Please install .NET 9 SDK:
    echo 1. Go to: https://dotnet.microsoft.com/download/dotnet/9.0
    echo 2. Download and install .NET 9.0 SDK
    echo 3. Restart your terminal
    echo 4. Run this script again
    echo.
    pause
    exit /b 1
)
echo [OK] .NET SDK found (version:
dotnet --version
echo )

REM Get database password
echo.
echo Database Configuration
echo =====================
set /p DB_PASSWORD="Enter PostgreSQL password for 'postgres' user: "

REM Set connection string
set SUPABASE_DB_URL=postgresql://postgres:%DB_PASSWORD%@localhost:5432/ethiopian_hdss

echo.
echo Creating database...
psql -U postgres -c "CREATE DATABASE ethiopian_hdss;" 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Database created
) else (
    echo [INFO] Database may already exist, continuing...
)

echo.
echo Applying migrations...
psql -U postgres -d ethiopian_hdss -f supabase\migrations\0001_enable_extensions.sql >nul 2>nul
if %ERRORLEVEL% EQU 0 (echo [OK] 0001_enable_extensions.sql) else (echo [WARN] 0001 may already be applied)

psql -U postgres -d ethiopian_hdss -f supabase\migrations\0002_schema.sql >nul 2>nul
if %ERRORLEVEL% EQU 0 (echo [OK] 0002_schema.sql) else (echo [WARN] 0002 may already be applied)

psql -U postgres -d ethiopian_hdss -f supabase\migrations\0003_functions.sql >nul 2>nul
if %ERRORLEVEL% EQU 0 (echo [OK] 0003_functions.sql) else (echo [WARN] 0003 may already be applied)

psql -U postgres -d ethiopian_hdss -f supabase\migrations\0004_ethiopian_adaptations.sql >nul 2>nul
if %ERRORLEVEL% EQU 0 (echo [OK] 0004_ethiopian_adaptations.sql) else (echo [WARN] 0004 may already be applied)

echo.
set /p LOAD_SAMPLE="Load sample Ethiopian data? (Y/N): "
if /i "%LOAD_SAMPLE%"=="Y" (
    echo Loading sample data...
    psql -U postgres -d ethiopian_hdss -f FakeData\ethiopian_sample_data.sql >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo [OK] Sample data loaded
    ) else (
        echo [WARN] Sample data may already exist
    )
)

echo.
echo Verifying installation...
for /f "tokens=*" %%i in ('psql -U postgres -d ethiopian_hdss -t -c "SELECT COUNT(*) FROM dss_individuals;"') do set RECORD_COUNT=%%i
echo [INFO] Total DSS individuals: %RECORD_COUNT%

echo.
echo ==================================
echo Deployment Complete!
echo ==================================
echo.
echo NEXT STEPS:
echo.
echo 1. Open TWO Command Prompt windows
echo.
echo 2. In Window 1 (API):
echo    cd PremiumMatcher\PremiumMatcher.Api
echo    set SUPABASE_DB_URL=%SUPABASE_DB_URL%
echo    dotnet run
echo.
echo 3. In Window 2 (Web):
echo    cd PremiumMatcher\PremiumMatcher\PremiumMatcher.Web
echo    dotnet run
echo.
echo 4. Open browser to: http://localhost:5142
echo.
echo Connection string saved to .env file
echo.
pause

REM Save connection string to .env file
echo SUPABASE_DB_URL=%SUPABASE_DB_URL% > .env
echo DB_HOST=localhost >> .env
echo DB_PORT=5432 >> .env
echo DB_NAME=ethiopian_hdss >> .env
echo DB_USER=postgres >> .env
