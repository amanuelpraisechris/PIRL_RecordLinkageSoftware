// Security Enhancements for Production
// Add these to Program.cs

using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add Authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
        };
    });

// Add Authorization with Roles
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("CanViewPII", policy =>
        policy.RequireRole("DataManager", "Researcher", "Admin"));

    options.AddPolicy("CanAssignMatches", policy =>
        policy.RequireRole("DataManager", "Admin"));

    options.AddPolicy("AdminOnly", policy =>
        policy.RequireRole("Admin"));
});

// Secure CORS - Restrict to specific domains
builder.Services.AddCors(options =>
{
    options.AddPolicy("Production",
        policy => policy
            .WithOrigins(
                "https://hdss.ephi.gov.et",
                "https://hdss.moh.gov.et"
            )
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials());
});

// Add Rate Limiting
builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("fixed", opt =>
    {
        opt.PermitLimit = 100;
        opt.Window = TimeSpan.FromMinutes(1);
        opt.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
    });
});

var app = builder.Build();

// Use Authentication & Authorization
app.UseAuthentication();
app.UseAuthorization();

// Use Rate Limiting
app.UseRateLimiter();

// Use Secure CORS
app.UseCors("Production");

// Force HTTPS in Production
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
    app.UseHsts();
}

// Protected Endpoints - Require Authentication
app.MapPost("/api/search", async (SearchRequest req) =>
{
    // ... existing code
})
.RequireAuthorization("CanViewPII")
.RequireRateLimiting("fixed");

app.MapPost("/api/matches", async (AssignMatchRequest req) =>
{
    // ... existing code
})
.RequireAuthorization("CanAssignMatches")
.RequireRateLimiting("fixed");

app.Run();
