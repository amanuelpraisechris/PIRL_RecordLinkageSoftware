using Microsoft.Data.SqlClient; // kept if later needed
using Npgsql;
using System.Data;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

// Dev CORS to allow the Web frontend during local development
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowDev",
        policy => policy
            .AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod());
});

// Configuration: expects SUPABASE_DB_URL (full Postgres connection string)
var supabaseConnString = Environment.GetEnvironmentVariable("SUPABASE_DB_URL")
    ?? builder.Configuration["Supabase:ConnectionString"]
    ?? string.Empty;

if (string.IsNullOrWhiteSpace(supabaseConnString))
{
    Console.WriteLine("Warning: SUPABASE_DB_URL not set. API endpoints will fail until configured.");
}

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors("AllowDev");

// DTOs are declared after Run() to satisfy top-level statement ordering

NpgsqlDataSource? dataSource = null;
if (!string.IsNullOrWhiteSpace(supabaseConnString))
{
    dataSource = NpgsqlDataSource.Create(supabaseConnString);
}

// POST /api/search -> calls SQL function search_candidates(...) in Supabase (Postgres)
app.MapPost("/api/search", async (SearchRequest req) =>
{
    if (dataSource is null) return Results.Problem("Database not configured", statusCode: 500);

    await using var conn = await dataSource.OpenConnectionAsync();

    const string sql = @"
        select * from public.search_candidates(
            _first_name => @first_name,
            _middle_name => @middle_name,
            _last_name => @last_name,
            _tl_first_name => @tl_first_name,
            _tl_middle_name => @tl_middle_name,
            _tl_last_name => @tl_last_name,
            _gender => @gender,
            _bday => @bday,
            _bmonth => @bmonth,
            _byear => @byear,
            _village => @village,
            _subvillage => @subvillage,
            _use_first_name => @use_first_name,
            _use_middle_name => @use_middle_name,
            _use_last_name => @use_last_name,
            _use_tl_first_name => @use_tl_first_name,
            _use_tl_middle_name => @use_tl_middle_name,
            _use_tl_last_name => @use_tl_last_name,
            _use_gender => @use_gender,
            _use_bday => @use_bday,
            _use_bmonth => @use_bmonth,
            _use_byear => @use_byear,
            _use_village => @use_village,
            _use_subvillage => @use_subvillage
        );";

    await using var cmd = new NpgsqlCommand(sql, conn);
    cmd.Parameters.AddWithValue("first_name", (object?)req.FirstName ?? DBNull.Value);
    cmd.Parameters.AddWithValue("middle_name", (object?)req.MiddleName ?? DBNull.Value);
    cmd.Parameters.AddWithValue("last_name", (object?)req.LastName ?? DBNull.Value);
    cmd.Parameters.AddWithValue("tl_first_name", (object?)req.TLFirstName ?? DBNull.Value);
    cmd.Parameters.AddWithValue("tl_middle_name", (object?)req.TLMiddleName ?? DBNull.Value);
    cmd.Parameters.AddWithValue("tl_last_name", (object?)req.TLLastName ?? DBNull.Value);
    cmd.Parameters.AddWithValue("gender", (object?)req.Gender ?? DBNull.Value);
    cmd.Parameters.AddWithValue("bday", (object?)req.BDay ?? DBNull.Value);
    cmd.Parameters.AddWithValue("bmonth", (object?)req.BMonth ?? DBNull.Value);
    cmd.Parameters.AddWithValue("byear", (object?)req.BYear ?? DBNull.Value);
    cmd.Parameters.AddWithValue("village", (object?)req.Village ?? DBNull.Value);
    cmd.Parameters.AddWithValue("subvillage", (object?)req.SubVillage ?? DBNull.Value);
    cmd.Parameters.AddWithValue("use_first_name", req.UseFirstName);
    cmd.Parameters.AddWithValue("use_middle_name", req.UseMiddleName);
    cmd.Parameters.AddWithValue("use_last_name", req.UseLastName);
    cmd.Parameters.AddWithValue("use_tl_first_name", req.UseTLFirstName);
    cmd.Parameters.AddWithValue("use_tl_middle_name", req.UseTLMiddleName);
    cmd.Parameters.AddWithValue("use_tl_last_name", req.UseTLLastName);
    cmd.Parameters.AddWithValue("use_gender", req.UseGender);
    cmd.Parameters.AddWithValue("use_bday", req.UseBDay);
    cmd.Parameters.AddWithValue("use_bmonth", req.UseBMonth);
    cmd.Parameters.AddWithValue("use_byear", req.UseBYear);
    cmd.Parameters.AddWithValue("use_village", req.UseVillage);
    cmd.Parameters.AddWithValue("use_subvillage", req.UseSubVillage);

    var list = new List<Candidate>();
    await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.CloseConnection);
    while (await reader.ReadAsync())
    {
        list.Add(new Candidate(
            reader.GetString(reader.GetOrdinal("dss_id")),
            reader.IsDBNull(reader.GetOrdinal("birth_year")) ? null : reader.GetString(reader.GetOrdinal("birth_year")),
            reader.GetDouble(reader.GetOrdinal("score")),
            reader.GetInt32(reader.GetOrdinal("rank_no_gap")),
            reader.GetInt32(reader.GetOrdinal("rank_gap")),
            reader.GetInt32(reader.GetOrdinal("row_number")),
            reader.GetDouble(reader.GetOrdinal("name_score")),
            reader.IsDBNull(reader.GetOrdinal("location")) ? null : reader.GetString(reader.GetOrdinal("location")),
            reader.IsDBNull(reader.GetOrdinal("first_name")) ? null : reader.GetString(reader.GetOrdinal("first_name")),
            reader.IsDBNull(reader.GetOrdinal("middle_name")) ? null : reader.GetString(reader.GetOrdinal("middle_name")),
            reader.IsDBNull(reader.GetOrdinal("last_name")) ? null : reader.GetString(reader.GetOrdinal("last_name")),
            reader.IsDBNull(reader.GetOrdinal("gender")) ? null : reader.GetString(reader.GetOrdinal("gender"))
        ));
    }

    return Results.Ok(list);
});

// POST /api/matches -> inserts a match record
app.MapPost("/api/matches", async (AssignMatchRequest req) =>
{
    if (dataSource is null) return Results.Problem("Database not configured", statusCode: 500);
    await using var conn = await dataSource.OpenConnectionAsync();

    const string sql = @"
        insert into public.matches
        (record_no, facility, unique_ctcid_number, tgr_form_number, file_ref, ctc_infant,
         unique_htc, unique_anc, anc_infant, heid_infant, search_criteria,
         dss_id, score, rank_gap, rank_no_gap, row_number)
        values (@record_no, @facility, @u_ctc, @tgr, @file_ref, @ctc_inf, @u_htc, @u_anc, @anc_inf, @heid, @criteria,
                @dss_id, @score, @rank_gap, @rank_no_gap, @row_number)
        returning id;";

    await using var cmd = new NpgsqlCommand(sql, conn);
    cmd.Parameters.AddWithValue("record_no", req.RecordNo);
    cmd.Parameters.AddWithValue("facility", req.Facility);
    cmd.Parameters.AddWithValue("u_ctc", (object?)req.UniqueCTCIDNumber ?? DBNull.Value);
    cmd.Parameters.AddWithValue("tgr", (object?)req.TgrFormNumber ?? DBNull.Value);
    cmd.Parameters.AddWithValue("file_ref", (object?)req.FileRef ?? DBNull.Value);
    cmd.Parameters.AddWithValue("ctc_inf", (object?)req.CtcInfant ?? DBNull.Value);
    cmd.Parameters.AddWithValue("u_htc", (object?)req.UniqueHTC ?? DBNull.Value);
    cmd.Parameters.AddWithValue("u_anc", (object?)req.UniqueANC ?? DBNull.Value);
    cmd.Parameters.AddWithValue("anc_inf", (object?)req.AncInfant ?? DBNull.Value);
    cmd.Parameters.AddWithValue("heid", (object?)req.HeidInfant ?? DBNull.Value);
    cmd.Parameters.AddWithValue("criteria", req.SearchCriteria);
    cmd.Parameters.AddWithValue("dss_id", req.DssId);
    cmd.Parameters.AddWithValue("score", req.Score);
    cmd.Parameters.AddWithValue("rank_gap", req.RankGap);
    cmd.Parameters.AddWithValue("rank_no_gap", req.RankNoGap);
    cmd.Parameters.AddWithValue("row_number", req.RowNumber);

    var id = await cmd.ExecuteScalarAsync();
    return Results.Ok(new { id });
});

// POST /api/matches/exists -> duplication check by clinic IDs
app.MapPost("/api/matches/exists", async (MatchStatusRequest req) =>
{
    if (dataSource is null) return Results.Problem("Database not configured", statusCode: 500);
    await using var conn = await dataSource.OpenConnectionAsync();
    const string sql = @"
        select exists (
            select 1 from public.matches m
            where m.facility = @facility
              and coalesce(m.unique_ctcid_number,'') = coalesce(@u_ctc,'')
              and coalesce(m.tgr_form_number,'') = coalesce(@tgr,'')
              and coalesce(m.file_ref,'') = coalesce(@file_ref,'')
              and coalesce(m.ctc_infant,'') = coalesce(@ctc_inf,'')
              and coalesce(m.unique_htc,'') = coalesce(@u_htc,'')
              and coalesce(m.unique_anc,'') = coalesce(@u_anc,'')
              and coalesce(m.anc_infant,'') = coalesce(@anc_inf,'')
              and coalesce(m.heid_infant,'') = coalesce(@heid,'')
        );";
    await using var cmd = new NpgsqlCommand(sql, conn);
    cmd.Parameters.AddWithValue("facility", req.Facility);
    cmd.Parameters.AddWithValue("u_ctc", (object?)req.UniqueCTCIDNumber ?? DBNull.Value);
    cmd.Parameters.AddWithValue("tgr", (object?)req.TgrFormNumber ?? DBNull.Value);
    cmd.Parameters.AddWithValue("file_ref", (object?)req.FileRef ?? DBNull.Value);
    cmd.Parameters.AddWithValue("ctc_inf", (object?)req.CtcInfant ?? DBNull.Value);
    cmd.Parameters.AddWithValue("u_htc", (object?)req.UniqueHTC ?? DBNull.Value);
    cmd.Parameters.AddWithValue("u_anc", (object?)req.UniqueANC ?? DBNull.Value);
    cmd.Parameters.AddWithValue("anc_inf", (object?)req.AncInfant ?? DBNull.Value);
    cmd.Parameters.AddWithValue("heid", (object?)req.HeidInfant ?? DBNull.Value);

    var exists = (bool)(await cmd.ExecuteScalarAsync() ?? false);
    return Results.Ok(new { exists });
});

// POST /api/match-status -> summarize latest status by clinic IDs
app.MapPost("/api/match-status", async (MatchStatusRequest req) =>
{
    if (dataSource is null) return Results.Problem("Database not configured", statusCode: 500);
    await using var conn = await dataSource.OpenConnectionAsync();
    const string sql = @"
        select coalesce(max(status),'') as status, max(comment) as comment
        from public.match_status_view
        where facility = @facility
          and coalesce(unique_ctcid_number,'') = coalesce(@u_ctc,'')
          and coalesce(tgr_form_number,'') = coalesce(@tgr,'')
          and coalesce(file_ref,'') = coalesce(@file_ref,'')
          and coalesce(ctc_infant,'') = coalesce(@ctc_inf,'')
          and coalesce(unique_htc,'') = coalesce(@u_htc,'')
          and coalesce(unique_anc,'') = coalesce(@u_anc,'')
          and coalesce(anc_infant,'') = coalesce(@anc_inf,'')
          and coalesce(heid_infant,'') = coalesce(@heid,'');";

    await using var cmd = new NpgsqlCommand(sql, conn);
    cmd.Parameters.AddWithValue("facility", req.Facility);
    cmd.Parameters.AddWithValue("u_ctc", (object?)req.UniqueCTCIDNumber ?? DBNull.Value);
    cmd.Parameters.AddWithValue("tgr", (object?)req.TgrFormNumber ?? DBNull.Value);
    cmd.Parameters.AddWithValue("file_ref", (object?)req.FileRef ?? DBNull.Value);
    cmd.Parameters.AddWithValue("ctc_inf", (object?)req.CtcInfant ?? DBNull.Value);
    cmd.Parameters.AddWithValue("u_htc", (object?)req.UniqueHTC ?? DBNull.Value);
    cmd.Parameters.AddWithValue("u_anc", (object?)req.UniqueANC ?? DBNull.Value);
    cmd.Parameters.AddWithValue("anc_inf", (object?)req.AncInfant ?? DBNull.Value);
    cmd.Parameters.AddWithValue("heid", (object?)req.HeidInfant ?? DBNull.Value);

    await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.CloseConnection);
    if (await reader.ReadAsync())
    {
        var status = reader.IsDBNull(0) ? "" : reader.GetString(0);
        var comment = reader.IsDBNull(1) ? null : reader.GetString(1);
        return Results.Ok(new MatchStatusResponse(status, comment));
    }

    return Results.Ok(new MatchStatusResponse("", null));
});

app.Run();

// DTOs
record SearchRequest(
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

record Candidate(
    string DssId,
    string? BirthYear,
    double Score,
    int RankNoGap,
    int RankGap,
    int RowNumber,
    double NameScore,
    string? Location,
    string? FirstName,
    string? MiddleName,
    string? LastName,
    string? Gender
);

record AssignMatchRequest(
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

record MatchStatusRequest(string Facility, string? UniqueCTCIDNumber, string? TgrFormNumber, string? FileRef, string? CtcInfant, string? UniqueHTC, string? UniqueANC, string? AncInfant, string? HeidInfant);
record MatchStatusResponse(string Status, string? Comment);
