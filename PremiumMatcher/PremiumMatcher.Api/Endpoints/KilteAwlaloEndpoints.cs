// Kilte Awlalo HDSS Location API Endpoints
// Provides access to Tabias, Kushets, and Health Facilities

using Microsoft.AspNetCore.Mvc;
using Npgsql;
using System.Data;

namespace PremiumMatcher.Api.Endpoints;

public static class KilteAwlaloEndpoints
{
    public static void MapKilteAwlaloEndpoints(this WebApplication app, NpgsqlDataSource? dataSource)
    {
        var group = app.MapGroup("/api/kilte-awlalo")
            .WithTags("Kilte Awlalo HDSS");

        // GET /api/kilte-awlalo/tabias - Get all 10 Tabias
        group.MapGet("/tabias", async ([FromQuery] string? language) =>
        {
            if (dataSource is null) return Results.Problem("Database not configured", statusCode: 500);

            await using var conn = await dataSource.OpenConnectionAsync();
            const string sql = @"
                SELECT code, name_tigrinya, name_amharic, name_english, population_estimate
                FROM public.tabias
                WHERE woreda = 'Kilte Awlalo'
                ORDER BY name_english";

            await using var cmd = new NpgsqlCommand(sql, conn);
            await using var reader = await cmd.ExecuteReaderAsync();

            var tabias = new List<TabiaDto>();
            while (await reader.ReadAsync())
            {
                tabias.Add(new TabiaDto(
                    Code: reader.GetString(0),
                    NameTigrinya: reader.GetString(1),
                    NameAmharic: reader.IsDBNull(2) ? null : reader.GetString(2),
                    NameEnglish: reader.GetString(3),
                    PopulationEstimate: reader.IsDBNull(4) ? 0 : reader.GetInt32(4)
                ));
            }

            return Results.Ok(tabias);
        })
        .WithName("GetTabias")
        .WithSummary("Get all Kilte Awlalo Tabias")
        .Produces<List<TabiaDto>>();

        // GET /api/kilte-awlalo/kushets?tabiaCode={code} - Get Kushets for a Tabia
        group.MapGet("/kushets", async ([FromQuery] string? tabiaCode) =>
        {
            if (dataSource is null) return Results.Problem("Database not configured", statusCode: 500);

            await using var conn = await dataSource.OpenConnectionAsync();
            var sql = string.IsNullOrEmpty(tabiaCode)
                ? @"SELECT code, name_tigrinya, name_amharic, name_english, tabia_code, population_estimate
                    FROM public.kushets
                    ORDER BY name_english"
                : @"SELECT code, name_tigrinya, name_amharic, name_english, tabia_code, population_estimate
                    FROM public.kushets
                    WHERE tabia_code = @tabiaCode
                    ORDER BY name_english";

            await using var cmd = new NpgsqlCommand(sql, conn);
            if (!string.IsNullOrEmpty(tabiaCode))
                cmd.Parameters.AddWithValue("tabiaCode", tabiaCode);

            await using var reader = await cmd.ExecuteReaderAsync();

            var kushets = new List<KushetDto>();
            while (await reader.ReadAsync())
            {
                kushets.Add(new KushetDto(
                    Code: reader.GetString(0),
                    NameTigrinya: reader.GetString(1),
                    NameAmharic: reader.IsDBNull(2) ? null : reader.GetString(2),
                    NameEnglish: reader.GetString(3),
                    TabiaCode: reader.GetString(4),
                    PopulationEstimate: reader.IsDBNull(5) ? 0 : reader.GetInt32(5)
                ));
            }

            return Results.Ok(kushets);
        })
        .WithName("GetKushets")
        .WithSummary("Get Kushets (filtered by Tabia if specified)")
        .Produces<List<KushetDto>>();

        // GET /api/kilte-awlalo/facilities - Get all health facilities
        group.MapGet("/facilities", async ([FromQuery] string? facilityType) =>
        {
            if (dataSource is null) return Results.Problem("Database not configured", statusCode: 500);

            await using var conn = await dataSource.OpenConnectionAsync();
            var sql = string.IsNullOrEmpty(facilityType)
                ? @"SELECT code, name_tigrinya, name_amharic, name_english, facility_type,
                           tabia_code, catchment_population, services, has_electricity, has_internet
                    FROM public.health_facilities_kilte_awlalo
                    ORDER BY
                        CASE facility_type
                            WHEN 'General Hospital' THEN 1
                            WHEN 'Health Center' THEN 2
                            WHEN 'Health Post' THEN 3
                        END, name_english"
                : @"SELECT code, name_tigrinya, name_amharic, name_english, facility_type,
                           tabia_code, catchment_population, services, has_electricity, has_internet
                    FROM public.health_facilities_kilte_awlalo
                    WHERE facility_type = @facilityType
                    ORDER BY name_english";

            await using var cmd = new NpgsqlCommand(sql, conn);
            if (!string.IsNullOrEmpty(facilityType))
                cmd.Parameters.AddWithValue("facilityType", facilityType);

            await using var reader = await cmd.ExecuteReaderAsync();

            var facilities = new List<HealthFacilityDto>();
            while (await reader.ReadAsync())
            {
                facilities.Add(new HealthFacilityDto(
                    Code: reader.GetString(0),
                    NameTigrinya: reader.GetString(1),
                    NameAmharic: reader.IsDBNull(2) ? null : reader.GetString(2),
                    NameEnglish: reader.GetString(3),
                    FacilityType: reader.GetString(4),
                    TabiaCode: reader.IsDBNull(5) ? null : reader.GetString(5),
                    CatchmentPopulation: reader.IsDBNull(6) ? 0 : reader.GetInt32(6),
                    Services: reader.IsDBNull(7) ? Array.Empty<string>() : reader.GetFieldValue<string[]>(7),
                    HasElectricity: !reader.IsDBNull(8) && reader.GetBoolean(8),
                    HasInternet: !reader.IsDBNull(9) && reader.GetBoolean(9)
                ));
            }

            return Results.Ok(facilities);
        })
        .WithName("GetHealthFacilities")
        .WithSummary("Get all Kilte Awlalo health facilities")
        .Produces<List<HealthFacilityDto>>();

        // GET /api/kilte-awlalo/locations/view - Get full location hierarchy
        group.MapGet("/locations/view", async () =>
        {
            if (dataSource is null) return Results.Problem("Database not configured", statusCode: 500);

            await using var conn = await dataSource.OpenConnectionAsync();
            const string sql = @"SELECT * FROM public.kilte_awlalo_locations LIMIT 100";

            await using var cmd = new NpgsqlCommand(sql, conn);
            await using var reader = await cmd.ExecuteReaderAsync();

            var locations = new List<LocationViewDto>();
            while (await reader.ReadAsync())
            {
                locations.Add(new LocationViewDto(
                    TabiaCode: reader.GetString(0),
                    TabiaNameTigrinya: reader.GetString(1),
                    TabiaNameEnglish: reader.GetString(2),
                    KushetCode: reader.IsDBNull(3) ? null : reader.GetString(3),
                    KushetNameTigrinya: reader.IsDBNull(4) ? null : reader.GetString(4),
                    KushetNameEnglish: reader.IsDBNull(5) ? null : reader.GetString(5),
                    TabiaPopulation: reader.IsDBNull(6) ? 0 : reader.GetInt32(6),
                    KushetPopulation: reader.IsDBNull(7) ? 0 : reader.GetInt32(7)
                ));
            }

            return Results.Ok(locations);
        })
        .WithName("GetLocationView")
        .WithSummary("Get full location hierarchy view")
        .Produces<List<LocationViewDto>>();

        // GET /api/kilte-awlalo/stats - Get summary statistics
        group.MapGet("/stats", async () =>
        {
            if (dataSource is null) return Results.Problem("Database not configured", statusCode: 500);

            await using var conn = await dataSource.OpenConnectionAsync();
            const string sql = @"
                SELECT
                    (SELECT COUNT(*) FROM public.tabias WHERE woreda = 'Kilte Awlalo') AS tabia_count,
                    (SELECT COUNT(*) FROM public.kushets) AS kushet_count,
                    (SELECT COUNT(*) FROM public.health_facilities_kilte_awlalo) AS facility_count,
                    (SELECT SUM(population_estimate) FROM public.tabias WHERE woreda = 'Kilte Awlalo') AS total_population,
                    (SELECT COUNT(*) FROM public.health_facilities_kilte_awlalo WHERE facility_type = 'General Hospital') AS hospital_count,
                    (SELECT COUNT(*) FROM public.health_facilities_kilte_awlalo WHERE facility_type = 'Health Center') AS health_center_count,
                    (SELECT COUNT(*) FROM public.health_facilities_kilte_awlalo WHERE facility_type = 'Health Post') AS health_post_count";

            await using var cmd = new NpgsqlCommand(sql, conn);
            await using var reader = await cmd.ExecuteReaderAsync();

            if (await reader.ReadAsync())
            {
                var stats = new KilteAwlaloStatsDto(
                    TabiaCount: reader.GetInt32(0),
                    KushetCount: reader.GetInt32(1),
                    FacilityCount: reader.GetInt32(2),
                    TotalPopulation: reader.IsDBNull(3) ? 0 : reader.GetInt32(3),
                    HospitalCount: reader.GetInt32(4),
                    HealthCenterCount: reader.GetInt32(5),
                    HealthPostCount: reader.GetInt32(6)
                );
                return Results.Ok(stats);
            }

            return Results.NotFound();
        })
        .WithName("GetKilteAwlaloStats")
        .WithSummary("Get summary statistics for Kilte Awlalo")
        .Produces<KilteAwlaloStatsDto>();
    }
}

// DTOs
public record TabiaDto(
    string Code,
    string NameTigrinya,
    string? NameAmharic,
    string NameEnglish,
    int PopulationEstimate
);

public record KushetDto(
    string Code,
    string NameTigrinya,
    string? NameAmharic,
    string NameEnglish,
    string TabiaCode,
    int PopulationEstimate
);

public record HealthFacilityDto(
    string Code,
    string NameTigrinya,
    string? NameAmharic,
    string NameEnglish,
    string FacilityType,
    string? TabiaCode,
    int CatchmentPopulation,
    string[] Services,
    bool HasElectricity,
    bool HasInternet
);

public record LocationViewDto(
    string TabiaCode,
    string TabiaNameTigrinya,
    string TabiaNameEnglish,
    string? KushetCode,
    string? KushetNameTigrinya,
    string? KushetNameEnglish,
    int TabiaPopulation,
    int KushetPopulation
);

public record KilteAwlaloStatsDto(
    int TabiaCount,
    int KushetCount,
    int FacilityCount,
    int TotalPopulation,
    int HospitalCount,
    int HealthCenterCount,
    int HealthPostCount
);
