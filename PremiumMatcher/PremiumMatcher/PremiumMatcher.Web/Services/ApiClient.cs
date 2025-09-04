using System.Net.Http.Json;

namespace PremiumMatcher.Web.Services;

public class ApiClient
{
    private readonly HttpClient _http;
    private readonly AppConfig _config;
    private string? _baseUrl;

    public ApiClient(HttpClient http, AppConfig config)
    {
        _http = http;
        _config = config;
    }

    private async Task<string> BaseUrl()
    {
        if (_baseUrl != null) return _baseUrl;
        var cfg = await _config.GetAsync();
        _baseUrl = string.IsNullOrWhiteSpace(cfg.ApiBaseUrl) ? string.Empty : cfg.ApiBaseUrl!.TrimEnd('/');
        return _baseUrl;
    }

    // DTOs mirrored from API
    public record SearchRequest(
        string? FirstName,
        string? MiddleName,
        string? LastName,
        string? TLFirstName,
        string? TLMiddleName,
        string? TLLastName,
        string? Gender,
        string? BDay,
        string? BMonth,
        string? BYear,
        string? Village,
        string? SubVillage,
        bool UseFirstName,
        bool UseMiddleName,
        bool UseLastName,
        bool UseTLFirstName,
        bool UseTLMiddleName,
        bool UseTLLastName,
        bool UseGender,
        bool UseBDay,
        bool UseBMonth,
        bool UseBYear,
        bool UseVillage,
        bool UseSubVillage
    );

    public record Candidate(
        string dssId,
        string? birthYear,
        double score,
        int rankNoGap,
        int rankGap,
        int rowNumber,
        double nameScore,
        string? location,
        string? firstName,
        string? middleName,
        string? lastName,
        string? gender
    );

    public record AssignMatchRequest(
        string RecordNo,
        string Facility,
        string? UniqueCTCIDNumber,
        string? TgrFormNumber,
        string? FileRef,
        string? CtcInfant,
        string? UniqueHTC,
        string? UniqueANC,
        string? AncInfant,
        string? HeidInfant,
        string SearchCriteria,
        string DssId,
        double Score,
        int RankGap,
        int RankNoGap,
        int RowNumber
    );

    public record ExistsResponse(bool exists);
    public record StatusRequest(string Facility, string? UniqueCTCIDNumber, string? TgrFormNumber, string? FileRef, string? CtcInfant, string? UniqueHTC, string? UniqueANC, string? AncInfant, string? HeidInfant);
    public record StatusResponse(string status, string? comment);

    public async Task<List<Candidate>> SearchAsync(SearchRequest req)
    {
        var baseUrl = await BaseUrl();
        var url = string.IsNullOrEmpty(baseUrl) ? "/api/search" : $"{baseUrl}/api/search";
        var resp = await _http.PostAsJsonAsync(url, req);
        resp.EnsureSuccessStatusCode();
        return (await resp.Content.ReadFromJsonAsync<List<Candidate>>()) ?? new();
    }

    public async Task<long> AssignMatchAsync(AssignMatchRequest req)
    {
        var baseUrl = await BaseUrl();
        var url = string.IsNullOrEmpty(baseUrl) ? "/api/matches" : $"{baseUrl}/api/matches";
        var resp = await _http.PostAsJsonAsync(url, req);
        resp.EnsureSuccessStatusCode();
        var json = await resp.Content.ReadFromJsonAsync<Dictionary<string, object>>() ?? new();
        return json.ContainsKey("id") ? Convert.ToInt64(json["id"]) : 0;
    }

    public async Task<bool> ExistsAsync(StatusRequest req)
    {
        var baseUrl = await BaseUrl();
        var url = string.IsNullOrEmpty(baseUrl) ? "/api/matches/exists" : $"{baseUrl}/api/matches/exists";
        var resp = await _http.PostAsJsonAsync(url, req);
        resp.EnsureSuccessStatusCode();
        var json = await resp.Content.ReadFromJsonAsync<ExistsResponse>();
        return json?.exists ?? false;
    }

    public async Task<StatusResponse?> StatusAsync(StatusRequest req)
    {
        var baseUrl = await BaseUrl();
        var url = string.IsNullOrEmpty(baseUrl) ? "/api/match-status" : $"{baseUrl}/api/match-status";
        var resp = await _http.PostAsJsonAsync(url, req);
        resp.EnsureSuccessStatusCode();
        return await resp.Content.ReadFromJsonAsync<StatusResponse>();
    }
}

