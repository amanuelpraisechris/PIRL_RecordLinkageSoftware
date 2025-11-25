# 🔐 Security Guide - Ethiopian HDSS Record Linkage System

**Last Updated:** 2025-11-25
**Security Level:** Development (needs hardening for production)

---

## 🎯 EXECUTIVE SUMMARY

### Current Security Status

| Aspect | Development | Production Ready |
|--------|-------------|------------------|
| SQL Injection | ✅ Protected | ✅ Ready |
| Authentication | ❌ None | ❌ **MUST ADD** |
| Authorization | ❌ None | ❌ **MUST ADD** |
| HTTPS/SSL | ❌ HTTP Only | ❌ **MUST ADD** |
| CORS | ❌ Allow All | ❌ **MUST FIX** |
| Input Validation | ⚠️ Partial | ❌ **MUST ADD** |
| Rate Limiting | ❌ None | ⚠️ **SHOULD ADD** |
| Audit Logging | ✅ Implemented | ✅ Ready |
| Data Encryption | ❌ Plain Text | ⚠️ **SHOULD ADD** |

**Overall:** 🟡 **Safe for local testing**, ❌ **NOT production-ready**

---

## 🚦 DEPLOYMENT SECURITY LEVELS

### Level 1: LOCAL TESTING ✅ Current State

**Scenario:** Single user on own computer, fake data

**Security Measures:**
- Local access only (localhost)
- No network exposure
- Fake/test data

**Risks:** ✅ Minimal (acceptable)

**Who Can Use:**
- Developers
- Testing team
- Single-user evaluation

**Action Required:** ✅ None - current state is adequate

---

### Level 2: OFFICE NETWORK 🟡 Minimal Security

**Scenario:** 2-5 users in same office, local WiFi, real data

**Security Measures Needed:**
1. ✅ Keep on local network (no internet)
2. ⚠️ Add basic authentication
3. ⚠️ Configure Windows Firewall
4. ⚠️ Use strong database password
5. ✅ Enable audit logging (already have)

**Risks:** 🟡 Medium (acceptable for pilot with supervision)

**Who Can Use:**
- Small HDSS sites (pilot phase)
- Supervised data entry teams
- Closed network environments

**Action Required:** Implement basic authentication (see Section 4)

---

### Level 3: PRODUCTION 🔴 Full Security Required

**Scenario:** Multiple sites, internet access, real patient data, regulatory compliance

**Security Measures REQUIRED:**
1. 🔴 **HTTPS with SSL certificate** (mandatory)
2. 🔴 **JWT Authentication** (mandatory)
3. 🔴 **Role-based authorization** (mandatory)
4. 🔴 **Secure CORS** (mandatory)
5. 🔴 **Input validation** (mandatory)
6. 🟡 **Rate limiting** (recommended)
7. 🟡 **Session management** (recommended)
8. 🟡 **Data encryption** (recommended for PII)
9. 🟡 **Regular security audits** (recommended)
10. 🟡 **Penetration testing** (recommended)

**Risks:** 🔴 Critical without these measures

**Who Can Use:**
- National HDSS network
- Multi-site deployments
- Internet-accessible systems
- Production with real patient data

**Action Required:** Complete production security checklist (see Section 5)

---

## 📋 DETAILED SECURITY ASSESSMENT

### 1. SQL Injection Protection ✅ SECURE

**Status:** ✅ **PROTECTED**

**Implementation:**
```csharp
// Parameterized queries prevent SQL injection
cmd.Parameters.AddWithValue("first_name", req.FirstName);
```

**Test:**
```
Try to inject: Abebe'; DROP TABLE dss_individuals; --
Result: ✅ Treated as literal string, attack fails
```

**Verdict:** Production-ready ✅

---

### 2. Authentication ❌ NOT IMPLEMENTED

**Status:** ❌ **CRITICAL VULNERABILITY**

**Current State:**
- No login page
- No passwords
- Anyone with URL can access
- No user accounts

**Risk Scenario:**
```
Attacker finds URL: http://your-server:5142
Attacker opens browser
Attacker has FULL ACCESS to:
  - Search all HDSS records
  - View sensitive patient data
  - Assign/modify matches
  - No accountability
```

**Impact:** 🔴 **CRITICAL** - Cannot use for real data

**Fix Required:** Implement JWT authentication (see Section 4.1)

---

### 3. Authorization ❌ NOT IMPLEMENTED

**Status:** ❌ **CRITICAL VULNERABILITY**

**Current State:**
- No user roles
- No permission checks
- Everyone can do everything

**Risk Scenario:**
```
Data Entry Clerk (should only search):
  ✅ Can search (correct)
  ❌ Can assign matches (wrong - should be supervisor only)
  ❌ Can export data (wrong - should be admin only)
  ❌ Can delete records (wrong - should be admin only)
```

**Impact:** 🔴 **CRITICAL** - No access control

**Fix Required:** Implement role-based access control (see Section 4.2)

---

### 4. HTTPS/SSL ❌ NOT CONFIGURED

**Status:** ❌ **HIGH RISK**

**Current State:**
```
Connection: http://localhost:5142 (not https://)
Data transmitted: PLAIN TEXT
```

**Risk Scenario:**
```
User searches for: "Abebe Bekele, HIV positive"
Data sent over network: PLAIN TEXT
Attacker on WiFi: Can intercept and read
Result: Patient privacy violated
```

**Impact:** 🔴 **HIGH** - Data can be intercepted

**Fix Required:** Configure SSL certificate (see Section 4.3)

---

### 5. CORS Security ❌ INSECURE

**Status:** ❌ **HIGH RISK**

**Current Code:**
```csharp
policy => policy
    .AllowAnyOrigin()  // ❌ DANGEROUS!
```

**Risk Scenario:**
```
Malicious website: evil.com
Evil.com creates page with JavaScript
JavaScript calls: http://your-server:5151/api/search
Your API responds: ✅ (because AllowAnyOrigin)
Evil site now has access to your data!
```

**Impact:** 🔴 **HIGH** - Cross-site request attacks

**Fix Required:** Restrict to specific domains (see Section 4.4)

---

### 6. Input Validation ⚠️ PARTIAL

**Status:** ⚠️ **MEDIUM RISK**

**Current State:**
- No length validation
- No format checking
- No special character filtering

**Risk Scenarios:**
```
Scenario 1: Buffer Overflow
  Input: First name = "A" * 10000 (10,000 characters)
  Result: Could crash system

Scenario 2: XSS Attack
  Input: First name = "<script>alert('hacked')</script>"
  Result: JavaScript executed in browser

Scenario 3: Invalid Data
  Input: Birth year = "abc123"
  Result: Database error or corrupt data
```

**Impact:** 🟡 **MEDIUM** - Data integrity issues

**Fix Required:** Add validation layer (see Section 4.5)

---

### 7. Rate Limiting ❌ NOT IMPLEMENTED

**Status:** ❌ **MEDIUM RISK**

**Current State:**
- Unlimited requests per second
- No throttling
- No IP-based limits

**Risk Scenario:**
```
Attacker script:
  for i in range(1000000):
      search("Abebe")

Result:
  - Server overload
  - Database crashes
  - Legitimate users blocked
  - Denial of Service
```

**Impact:** 🟡 **MEDIUM** - Service availability

**Fix Required:** Implement rate limiter (see Section 4.6)

---

### 8. Audit Logging ✅ IMPLEMENTED

**Status:** ✅ **GOOD** (but needs enhancement)

**Current Implementation:**
```sql
CREATE TABLE audit_log (
    user_email, action, dss_id, timestamp, details
);
```

**What's Logged:**
- Match assignments
- Database changes

**What's NOT Logged:**
- Search queries (should log for auditing)
- Failed login attempts (no auth yet)
- Unauthorized access attempts

**Verdict:** Good foundation, enhance when auth added

---

### 9. Data Encryption ❌ PLAIN TEXT

**Status:** ❌ **MEDIUM RISK**

**Current State:**
```sql
-- Data stored in plain text
dss_individuals:
  first_name: "Abebe"
  birth_year: "1985"
  -- Anyone with DB access can read
```

**Risk Scenario:**
```
Database backup stolen:
  Backup file: ethiopian_hdss.dump
  Attacker restores backup
  Attacker reads: All patient names, DOBs, locations
  Result: Privacy breach
```

**Impact:** 🟡 **MEDIUM-HIGH** - Depends on data sensitivity

**Fix Required:** Encrypt sensitive fields (see Section 4.7)

---

## 🛠️ SECURITY IMPLEMENTATION GUIDE

### 4.1 Add Authentication (JWT)

#### Step 1: Install Packages

```bash
cd PremiumMatcher/PremiumMatcher.Api
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package System.IdentityModel.Tokens.Jwt
```

#### Step 2: Create User Management

```sql
-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL, -- 'admin', 'data_manager', 'viewer'
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ
);

-- Add some users
INSERT INTO users (username, email, password_hash, role) VALUES
('admin', 'admin@ephi.gov.et', '$2a$11$hashed_password', 'admin'),
('datamanager', 'data@ephi.gov.et', '$2a$11$hashed_password', 'data_manager');
```

#### Step 3: Update Program.cs

See `Program.Production.Security.cs` for full implementation.

#### Step 4: Add Login Endpoint

```csharp
app.MapPost("/api/login", async (LoginRequest req) =>
{
    // Verify credentials
    var user = await GetUserByUsername(req.Username);
    if (user == null || !VerifyPassword(req.Password, user.PasswordHash))
        return Results.Unauthorized();

    // Generate JWT token
    var token = GenerateJwtToken(user);
    return Results.Ok(new { token });
});
```

---

### 4.2 Add Authorization (Roles)

#### Define Roles:

```csharp
// Admin: Full access
// DataManager: Search and assign matches
// Viewer: Search only (read-only)

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("CanSearch", policy =>
        policy.RequireRole("Admin", "DataManager", "Viewer"));

    options.AddPolicy("CanAssign", policy =>
        policy.RequireRole("Admin", "DataManager"));

    options.AddPolicy("AdminOnly", policy =>
        policy.RequireRole("Admin"));
});
```

#### Protect Endpoints:

```csharp
app.MapPost("/api/search", async (SearchRequest req) =>
{
    // ... search logic
})
.RequireAuthorization("CanSearch");

app.MapPost("/api/matches", async (AssignMatchRequest req) =>
{
    // ... match logic
})
.RequireAuthorization("CanAssign");
```

---

### 4.3 Enable HTTPS

#### Option A: Self-Signed Certificate (Development/Internal)

```bash
# Generate certificate
dotnet dev-certs https --trust

# Update launchSettings.json
"applicationUrl": "https://localhost:7163;http://localhost:5142"
```

#### Option B: Let's Encrypt (Production)

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d hdss.ephi.gov.et

# Auto-renew
sudo certbot renew --dry-run
```

#### Option C: Commercial Certificate

Purchase SSL certificate from:
- DigiCert
- GlobalSign
- Let's Encrypt (free)

---

### 4.4 Secure CORS

#### Update Program.cs:

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("Production",
        policy => policy
            .WithOrigins(
                "https://hdss.ephi.gov.et",
                "https://hdss.moh.gov.et"
            ) // ✅ Specific domains only!
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials());
});

app.UseCors("Production");
```

---

### 4.5 Add Input Validation

#### Install FluentValidation:

```bash
dotnet add package FluentValidation
dotnet add package FluentValidation.AspNetCore
```

#### Create Validators:

```csharp
public class SearchRequestValidator : AbstractValidator<SearchRequest>
{
    public SearchRequestValidator()
    {
        RuleFor(x => x.FirstName)
            .MaximumLength(100)
            .Matches("^[a-zA-Z\\s]*$")
            .When(x => !string.IsNullOrEmpty(x.FirstName));

        RuleFor(x => x.BYear)
            .Must(BeValidYear)
            .When(x => !string.IsNullOrEmpty(x.BYear));
    }

    private bool BeValidYear(string? year)
    {
        if (string.IsNullOrEmpty(year)) return true;
        return int.TryParse(year, out var y) && y >= 1900 && y <= DateTime.Now.Year;
    }
}
```

---

### 4.6 Add Rate Limiting

#### Install Package:

```bash
dotnet add package Microsoft.AspNetCore.RateLimiting
```

#### Configure:

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("api", opt =>
    {
        opt.PermitLimit = 100;  // 100 requests
        opt.Window = TimeSpan.FromMinutes(1);  // per minute
    });
});

app.UseRateLimiter();

// Apply to endpoints
app.MapPost("/api/search", ...)
   .RequireRateLimiting("api");
```

---

### 4.7 Encrypt Sensitive Data

#### Transparent Data Encryption (PostgreSQL):

```sql
-- Enable pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Encrypt sensitive fields
CREATE TABLE dss_individuals_encrypted (
    id UUID PRIMARY KEY,
    dss_id TEXT,
    first_name_encrypted BYTEA,  -- Encrypted
    birth_year_encrypted BYTEA    -- Encrypted
);

-- Insert encrypted data
INSERT INTO dss_individuals_encrypted (dss_id, first_name_encrypted)
VALUES ('ETH-001', pgp_sym_encrypt('Abebe', 'encryption_key'));

-- Query decrypted data
SELECT dss_id, pgp_sym_decrypt(first_name_encrypted, 'encryption_key') as first_name
FROM dss_individuals_encrypted;
```

---

## 🇪🇹 ETHIOPIAN COMPLIANCE REQUIREMENTS

### Legal Framework:

1. **Ethiopian Data Protection Law (Draft)**
   - Personal data protection
   - Data subject rights
   - Security measures required

2. **Ministry of Health Regulations**
   - Health information privacy
   - Patient consent requirements
   - Data breach notification

3. **International Standards** (if partnering with EU/US)
   - GDPR compliance (if EU partners)
   - HIPAA awareness (if US partners)

### Required Measures for Ethiopia:

```
Priority 1 (Legal Requirement):
✅ User authentication
✅ Access control (role-based)
✅ Audit logging (who accessed what)
✅ Data encryption (HTTPS)
✅ Consent tracking

Priority 2 (Best Practice):
✅ Data minimization
✅ Purpose limitation
✅ Regular security audits
✅ Incident response plan
✅ Staff training
```

---

## 🚨 SECURITY INCIDENT RESPONSE

### If Security Breach Occurs:

```
Step 1: IMMEDIATE (Within 1 hour)
  1. Isolate affected system
  2. Block attacker IP
  3. Notify EPHI security team
  4. Preserve logs/evidence

Step 2: ASSESSMENT (Within 24 hours)
  1. Determine scope of breach
  2. Identify compromised data
  3. Assess risk level
  4. Document incident

Step 3: NOTIFICATION (Within 72 hours)
  1. Notify Ethiopian Data Protection Authority
  2. Inform affected individuals (if PII exposed)
  3. Report to EPHI leadership
  4. Coordinate with MOH

Step 4: REMEDIATION
  1. Patch vulnerabilities
  2. Reset passwords
  3. Update security measures
  4. Conduct post-mortem

Step 5: PREVENTION
  1. Implement lessons learned
  2. Update security policies
  3. Retrain staff
  4. Enhanced monitoring
```

---

## ✅ PRODUCTION DEPLOYMENT CHECKLIST

### Pre-Deployment Security Audit:

```
Authentication & Authorization:
☐ JWT authentication implemented
☐ User roles defined (admin, data_manager, viewer)
☐ Login page functional
☐ Password policy enforced (min 8 chars, complexity)
☐ Account lockout after failed attempts
☐ Session timeout configured (30 minutes)

Network Security:
☐ HTTPS enabled with valid SSL certificate
☐ HTTP redirects to HTTPS
☐ CORS restricted to specific domains
☐ Firewall rules configured
☐ VPN/private network for admin access

Application Security:
☐ Input validation on all endpoints
☐ Rate limiting configured
☐ SQL injection testing passed
☐ XSS protection verified
☐ CSRF tokens implemented

Data Security:
☐ Database passwords are strong (20+ chars)
☐ Connection strings in environment variables
☐ Sensitive fields encrypted (if required)
☐ Backups encrypted
☐ Backup storage secure

Logging & Monitoring:
☐ Audit logging enabled
☐ Failed login attempts logged
☐ Suspicious activity alerts configured
☐ Log rotation configured
☐ Log retention policy defined

Compliance:
☐ Ethiopian data protection law reviewed
☐ MOH regulations compliance verified
☐ User consent mechanisms in place
☐ Privacy policy published
☐ Data retention policy documented

Testing:
☐ Penetration testing completed
☐ Security audit passed
☐ Load testing completed
☐ Disaster recovery plan tested
☐ Incident response plan documented

Documentation:
☐ Security policies written
☐ User training materials ready
☐ Admin documentation complete
☐ Incident response procedures documented
☐ Contact list for emergencies
```

---

## 🎓 SECURITY TRAINING

### For Data Managers:

```
Topics to Cover:
1. Password security
   - Strong passwords
   - Never share passwords
   - Regular password changes

2. Physical security
   - Lock computer when away
   - Secure logout procedures
   - Visitor protocols

3. Data handling
   - Minimum necessary principle
   - No screenshots of patient data
   - Secure data disposal

4. Incident reporting
   - How to report suspicious activity
   - Who to contact
   - What to document
```

### For Administrators:

```
Topics to Cover:
1. Security configuration
2. User management
3. Backup procedures
4. Log monitoring
5. Incident response
6. Patch management
```

---

## 📞 SECURITY CONTACTS

### Ethiopian HDSS Security Team:

```
Primary Contact:
  Name: [System Administrator]
  Email: security@ephi.gov.et
  Phone: +251-11-xxx-xxxx

EPHI IT Security:
  Email: it-security@ephi.gov.et

Ministry of Health Cyber Security:
  Email: cybersecurity@moh.gov.et

Emergency (After Hours):
  Phone: +251-9xx-xxx-xxx
```

---

## 🔄 SECURITY MAINTENANCE

### Regular Tasks:

```
Daily:
☐ Review audit logs for suspicious activity
☐ Monitor system performance
☐ Check backup status

Weekly:
☐ Review failed login attempts
☐ Check for security updates
☐ Verify backup integrity

Monthly:
☐ User access review
☐ Security patch updates
☐ Test disaster recovery
☐ Review security policies

Quarterly:
☐ Security training refresher
☐ Penetration testing
☐ Third-party security audit
☐ Compliance review

Annually:
☐ Comprehensive security audit
☐ Policy review and updates
☐ Incident response drill
☐ Staff security awareness exam
```

---

## 🎯 SUMMARY

### Current State:
- ✅ Safe for LOCAL TESTING with FAKE DATA
- ❌ NOT safe for PRODUCTION with REAL DATA

### To Make Production-Ready:
1. Add authentication (JWT)
2. Add authorization (roles)
3. Enable HTTPS (SSL certificate)
4. Secure CORS (specific domains)
5. Add input validation
6. Implement rate limiting
7. Encrypt sensitive data
8. Regular security audits

### Timeline:
- Basic security (auth + HTTPS): 1-2 weeks
- Full production security: 4-6 weeks
- Security testing & audit: 2-4 weeks
**Total:** 2-3 months for full production readiness

---

**For implementation assistance, contact:**
- EPHI IT Security Team
- Ethiopian Cyber Security Center
- International security consultants (if budget available)

---

**🔒 Security is a JOURNEY, not a destination. Continuously improve! 🇪🇹**
