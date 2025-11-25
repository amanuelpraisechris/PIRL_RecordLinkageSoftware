# 🪟 Windows Installation Guide

Complete guide for installing and running Ethiopian HDSS on Windows 10/11.

---

## 📋 Prerequisites Installation

### Step 1: Install PostgreSQL (5 minutes)

1. **Download:**
   - Go to: https://www.postgresql.org/download/windows/
   - Click "Download the installer"
   - Choose: **PostgreSQL 16.x** (Windows x86-64)
   - File size: ~350 MB

2. **Install:**
   - Run the downloaded `.exe` file
   - Click "Next" on welcome screen
   - **Installation Directory:** `C:\Program Files\PostgreSQL\16` (default)
   - Click "Next"
   - **Select Components:** Check all (PostgreSQL Server, pgAdmin 4, Command Line Tools)
   - Click "Next"
   - **Data Directory:** `C:\Program Files\PostgreSQL\16\data` (default)
   - Click "Next"
   - **Password:** Enter and remember password for `postgres` superuser
     - Example: `postgres123` (use a strong password!)
     - **Write this down!** You'll need it later.
   - Click "Next"
   - **Port:** `5432` (default)
   - Click "Next"
   - **Locale:** `English, United States` (or your preference)
   - Click "Next"
   - Review settings and click "Next"
   - Wait for installation (2-3 minutes)
   - **Uncheck** "Launch Stack Builder" at the end
   - Click "Finish"

3. **Verify Installation:**
   ```cmd
   # Open Command Prompt (Win + R, type "cmd", press Enter)
   psql --version
   ```

   Should show: `psql (PostgreSQL) 16.x`

   If you get "command not found", restart your terminal.

---

### Step 2: Install .NET 9 SDK (3 minutes)

1. **Download:**
   - Go to: https://dotnet.microsoft.com/download/dotnet/9.0
   - Click **"Download .NET 9.0 SDK"** (not Runtime!)
   - Choose: **Windows x64** installer
   - File: `dotnet-sdk-9.0.xxx-win-x64.exe` (~200 MB)

2. **Install:**
   - Run the downloaded `.exe` file
   - Click "Install"
   - Wait for installation (2-3 minutes)
   - Click "Close"

3. **Verify Installation:**
   ```cmd
   # Close and re-open Command Prompt (important!)
   dotnet --version
   ```

   Should show: `9.0.xxx`

---

## 🚀 Quick Start (Windows)

### Method 1: Automated Script (Recommended)

**Open Command Prompt as Administrator:**
1. Press `Win + X`
2. Click "Terminal (Admin)" or "Command Prompt (Admin)"
3. Navigate to project:
   ```cmd
   cd %USERPROFILE%\PIRL_RecordLinkageSoftware
   ```

**Run the deployment script:**
```cmd
deploy-ethiopian-windows.bat
```

The script will:
- ✅ Check prerequisites
- ✅ Create database
- ✅ Apply migrations
- ✅ Load sample data (optional)
- ✅ Show next steps

---

### Method 2: Manual Installation

#### Step 1: Create Database

**Open Command Prompt:**
```cmd
# Create database
psql -U postgres -c "CREATE DATABASE ethiopian_hdss;"
# Enter your postgres password when prompted
```

#### Step 2: Apply Migrations

```cmd
# Navigate to project directory
cd %USERPROFILE%\PIRL_RecordLinkageSoftware

# Apply migrations (enter password for each)
psql -U postgres -d ethiopian_hdss -f supabase\migrations\0001_enable_extensions.sql
psql -U postgres -d ethiopian_hdss -f supabase\migrations\0002_schema.sql
psql -U postgres -d ethiopian_hdss -f supabase\migrations\0003_functions.sql
psql -U postgres -d ethiopian_hdss -f supabase\migrations\0004_ethiopian_adaptations.sql
```

#### Step 3: Load Sample Data (Optional)

```cmd
psql -U postgres -d ethiopian_hdss -f FakeData\ethiopian_sample_data.sql
```

#### Step 4: Configure Environment

**Create `.env` file in project root:**
```cmd
notepad .env
```

**Add this content** (replace YOUR_PASSWORD):
```
SUPABASE_DB_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/ethiopian_hdss
```

Save and close.

---

## 🏃 Running the Application

You need **TWO Command Prompt windows** open.

### Window 1: Start API

**Open Command Prompt #1:**
```cmd
cd %USERPROFILE%\PIRL_RecordLinkageSoftware\PremiumMatcher\PremiumMatcher.Api

REM Set environment variable (replace YOUR_PASSWORD)
set SUPABASE_DB_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/ethiopian_hdss

REM Run API
dotnet run
```

**Expected output:**
```
Building...
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5151
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
```

✅ **Leave this window open!**

---

### Window 2: Start Web Frontend

**Open Command Prompt #2:**
```cmd
cd %USERPROFILE%\PIRL_RecordLinkageSoftware\PremiumMatcher\PremiumMatcher\PremiumMatcher.Web

REM Run Web
dotnet run
```

**Expected output:**
```
Building...
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5142
      Now listening on: https://localhost:7163
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
```

**Browser will auto-open to:** http://localhost:5142

✅ **Leave this window open!**

---

## 🌐 Access the Application

**Open your web browser:**
- **HTTP:** http://localhost:5142
- **HTTPS:** https://localhost:7163

You should see the **Record Matching** page!

---

## 🧪 Test the System

### Test 1: Search for a Person

1. Go to: http://localhost:5142/match
2. Enter:
   - **First Name:** `Abebe`
   - **Father's Name:** `Bekele`
   - **Gender:** `Male`
   - **Birth Year:** `1985`
3. Check: ☑ Use First Name, ☑ Use Father Name, ☑ Use Gender, ☑ Use Birth Year
4. Click **"Search"**

**Expected:** Should find record `ETH-AM-001` with high score (>0.8)

### Test 2: Assign a Match

1. Click **"Select"** on the best match
2. Fill in:
   - **Health Facility:** `Gondar Health Center`
   - **Record Number:** `REC-001`
   - **EMR Number:** `EMR-12345`
3. Click **"Assign Match"**

**Expected:** Success message with match ID

---

## 🛠️ Troubleshooting

### Issue: "psql: command not found"

**Solution:** Add PostgreSQL to PATH

1. Press `Win + X`, select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "System variables", find "Path", click "Edit"
5. Click "New" and add:
   ```
   C:\Program Files\PostgreSQL\16\bin
   ```
6. Click "OK" on all dialogs
7. **Restart Command Prompt**

---

### Issue: "dotnet: command not found"

**Solution:** Restart your terminal after installing .NET SDK

1. Close all Command Prompt windows
2. Open a new Command Prompt
3. Try again: `dotnet --version`

---

### Issue: "Password authentication failed"

**Solution:** Check your PostgreSQL password

```cmd
# Test connection
psql -U postgres -c "SELECT version();"
# Enter password when prompted
```

If still fails, reset password:
1. Open pgAdmin 4
2. Right-click "postgres" user
3. Select "Properties"
4. Go to "Definition" tab
5. Enter new password
6. Click "Save"

---

### Issue: "Port 5151 already in use"

**Solution:** Kill process using port

```cmd
# Find process
netstat -ano | findstr :5151

# Kill process (replace PID)
taskkill /PID <PID> /F
```

---

### Issue: "Cannot connect to database"

**Solution:** Ensure PostgreSQL service is running

1. Press `Win + R`
2. Type `services.msc`, press Enter
3. Find "postgresql-x64-16"
4. Right-click → "Start" (if not running)

---

## 📱 Access from Other Devices

### Same Network Access

**Find your computer's IP:**
```cmd
ipconfig
```

Look for "IPv4 Address" under your network adapter (e.g., `192.168.1.100`)

**Access from other devices:**
- Open browser on phone/tablet/other PC
- Go to: `http://192.168.1.100:5142`

**Enable Windows Firewall:**
```cmd
# Run as Administrator
netsh advfirewall firewall add rule name="HDSS Web" dir=in action=allow protocol=TCP localport=5142
netsh advfirewall firewall add rule name="HDSS API" dir=in action=allow protocol=TCP localport=5151
```

---

## 🔄 Daily Usage

### Starting the System

**Every time you want to use the app:**

1. **Start API** (Command Prompt 1):
   ```cmd
   cd %USERPROFILE%\PIRL_RecordLinkageSoftware\PremiumMatcher\PremiumMatcher.Api
   set SUPABASE_DB_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/ethiopian_hdss
   dotnet run
   ```

2. **Start Web** (Command Prompt 2):
   ```cmd
   cd %USERPROFILE%\PIRL_RecordLinkageSoftware\PremiumMatcher\PremiumMatcher\PremiumMatcher.Web
   dotnet run
   ```

3. **Open Browser:** http://localhost:5142

### Stopping the System

- Press `Ctrl + C` in both Command Prompt windows
- Close the windows

---

## 🚀 Create Desktop Shortcuts (Optional)

### Shortcut 1: Start API

1. Right-click Desktop → New → Shortcut
2. Location:
   ```
   cmd /k "cd /d %USERPROFILE%\PIRL_RecordLinkageSoftware\PremiumMatcher\PremiumMatcher.Api && set SUPABASE_DB_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/ethiopian_hdss && dotnet run"
   ```
3. Name: `HDSS API`
4. Change icon (optional)

### Shortcut 2: Start Web

1. Right-click Desktop → New → Shortcut
2. Location:
   ```
   cmd /k "cd /d %USERPROFILE%\PIRL_RecordLinkageSoftware\PremiumMatcher\PremiumMatcher\PremiumMatcher.Web && dotnet run"
   ```
3. Name: `HDSS Web`
4. Change icon (optional)

**Usage:**
1. Double-click "HDSS API"
2. Double-click "HDSS Web"
3. Browser opens automatically!

---

## 💾 Backup Database

### Manual Backup

```cmd
# Backup to file
pg_dump -U postgres -d ethiopian_hdss -F c -f ethiopian_hdss_backup.dump

# Restore from backup
pg_restore -U postgres -d ethiopian_hdss -c ethiopian_hdss_backup.dump
```

### Scheduled Backup (Task Scheduler)

Create `backup.bat`:
```bat
@echo off
set BACKUP_DIR=C:\HDSS_Backups
set BACKUP_FILE=%BACKUP_DIR%\ethiopian_hdss_%date:~-4,4%%date:~-10,2%%date:~-7,2%.dump

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

pg_dump -U postgres -d ethiopian_hdss -F c -f "%BACKUP_FILE%"

echo Backup completed: %BACKUP_FILE%
```

Schedule in Task Scheduler:
1. Open Task Scheduler
2. Create Basic Task
3. Name: "HDSS Backup"
4. Trigger: Daily, 2:00 AM
5. Action: Start a program
6. Program: `C:\path\to\backup.bat`
7. Finish

---

## 📊 System Requirements

### Minimum:
- **OS:** Windows 10 (64-bit) or Windows 11
- **CPU:** Intel Core i3 / AMD Ryzen 3
- **RAM:** 4 GB
- **Storage:** 20 GB free space
- **Network:** Not required (runs locally)

### Recommended:
- **OS:** Windows 11 Pro
- **CPU:** Intel Core i5 / AMD Ryzen 5
- **RAM:** 8 GB
- **Storage:** 50 GB SSD
- **Network:** Ethernet or WiFi (for multi-user)

---

## 🆘 Getting Help

### Check Logs

**API logs:**
```cmd
cd %USERPROFILE%\PIRL_RecordLinkageSoftware\PremiumMatcher\PremiumMatcher.Api
type logs\app.log
```

**Database logs:**
```
C:\Program Files\PostgreSQL\16\data\log\
```

### Common Commands

```cmd
# Check PostgreSQL status
sc query postgresql-x64-16

# Restart PostgreSQL
net stop postgresql-x64-16
net start postgresql-x64-16

# View database size
psql -U postgres -d ethiopian_hdss -c "\l+"

# Count records
psql -U postgres -d ethiopian_hdss -c "SELECT COUNT(*) FROM dss_individuals;"
```

---

## ✅ Installation Complete!

You now have:
- ✅ PostgreSQL database with Ethiopian HDSS schema
- ✅ .NET 9 SDK for running the application
- ✅ Sample Ethiopian data (25 records)
- ✅ Working web application
- ✅ API and frontend configured

**Start using:**
1. Run API (Window 1)
2. Run Web (Window 2)
3. Open http://localhost:5142
4. Start matching records!

---

**🎉 Welcome to Ethiopian HDSS Record Linkage! እንኳን ደህና መጡ! 🇪🇹**
