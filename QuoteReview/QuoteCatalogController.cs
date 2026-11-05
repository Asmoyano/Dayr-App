using System.Data;
using System.Data.Common;
using System.Globalization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[ApiController]
[Authorize(Policy = "DayrQuoteCatalog")]
[Route("v1/quote-catalog")]
public sealed class QuoteCatalogController(DbDataSource dataSource) : ControllerBase
{
    [HttpGet("clients")]
    public Task<ActionResult<IReadOnlyList<ClientItem>>> Clients(
        [FromQuery] string? after, [FromQuery] int limit = 50, CancellationToken cancellationToken = default) =>
        Read(null, after, limit, row => new ClientItem(row.GetString(0), row.GetString(1)), cancellationToken);

    [HttpGet("clients/{clientCode}/prices")]
    public Task<ActionResult<IReadOnlyList<PriceItem>>> Prices(
        string clientCode, [FromQuery] string? after, [FromQuery] int limit = 50,
        CancellationToken cancellationToken = default) =>
        Read(clientCode, after, limit, row => new PriceItem(
            row.GetString(0), row.GetString(1), row.GetString(2), row.GetBoolean(3),
            row.GetString(4), row.GetString(5), row.GetDecimal(6).ToString("F4", CultureInfo.InvariantCulture),
            row.GetString(7), AsUtc(row.GetDateTime(8)),
            row.IsDBNull(9) ? null : AsUtc(row.GetDateTime(9)), AsUtc(row.GetDateTime(10))),
            cancellationToken);

    private async Task<ActionResult<IReadOnlyList<T>>> Read<T>(
        string? client, string? after, int limit, Func<DbDataReader, T> map, CancellationToken cancellationToken)
    {
        var issuer = User.FindFirst("iss")?.Value;
        var subject = User.FindFirst("sub")?.Value;
        if (string.IsNullOrWhiteSpace(issuer) || issuer.Length > 200 ||
            string.IsNullOrWhiteSpace(subject) || subject.Length > 200)
            return Forbid();

        if (limit is < 1 or > 100 || !ValidCode(client) || !ValidCode(after))
            return BadRequest("Invalid catalog cursor, code or page size.");

        Response.Headers.CacheControl = "no-store";
        await using var command = dataSource.CreateCommand("dbo.LeerCatalogoCotizacion");
        command.CommandType = CommandType.StoredProcedure;
        Add(command, "@Emisor", DbType.String, issuer, 200);
        Add(command, "@Sujeto", DbType.String, subject, 200);
        Add(command, "@CodigoCliente", DbType.AnsiString, client, 30);
        Add(command, "@DespuesDe", DbType.AnsiString, after, 30);
        Add(command, "@Limite", DbType.Int32, limit, 0);
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var results = new List<T>();
        while (await reader.ReadAsync(cancellationToken))
            results.Add(map(reader));
        return Ok(results);
    }

    private static bool ValidCode(string? code) =>
        code is null || (code.Length is >= 1 and <= 30 && !string.IsNullOrWhiteSpace(code));

    private static DateTime AsUtc(DateTime value) => DateTime.SpecifyKind(value, DateTimeKind.Utc);

    private static void Add(DbCommand command, string name, DbType type, object? value, int size)
    {
        var parameter = command.CreateParameter();
        parameter.ParameterName = name;
        parameter.DbType = type;
        parameter.Size = size;
        parameter.Value = value ?? DBNull.Value;
        command.Parameters.Add(parameter);
    }
}

public sealed record ClientItem(string Code, string Name);

public sealed record PriceItem(string ProductCode, string Description, string Unit, bool AllowsFraction,
    string PriceList, string Currency, string NetUnitPrice, string SourceVersion, DateTime ValidFromUtc,
    DateTime? ValidUntilUtc, DateTime ReadAtUtc);
