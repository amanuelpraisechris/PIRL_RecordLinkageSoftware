using System.Net.Http.Json;

namespace PremiumMatcher.Web.Services;

public class AppConfig
{
    private readonly HttpClient _http;
    private AppSettings? _settings;

    public AppConfig(HttpClient http)
    {
        _http = http;
    }

    public async Task<AppSettings> GetAsync()
    {
        if (_settings != null) return _settings;
        // Load from wwwroot/appsettings.json at runtime
        _settings = await _http.GetFromJsonAsync<AppSettings>("appsettings.json")
                    ?? new AppSettings();
        return _settings;
    }
}

public class AppSettings
{
    public string? ApiBaseUrl { get; set; }
    public double LowNameScoreThreshold { get; set; } = 0.35; // tune as needed for Postgres scale 0..1
    public int BirthYearGapWarn { get; set; } = 10;
}

