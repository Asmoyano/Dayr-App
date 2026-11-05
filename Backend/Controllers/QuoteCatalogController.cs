using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Data.Common;
using System.Globalization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace Backend.Controllers;

[ApiController]
[Authorize(Policy = "DayrQuoteCatalog")]
[Route("v1/quote-catalog")]
[ProducesResponseType<ValidationProblemDetails>(StatusCodes.Status400BadRequest)]
[ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized)]
[ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden)]
[ProducesResponseType<ProblemDetails>(StatusCodes.Status503ServiceUnavailable)]
public sealed class QuoteCatalogController : ControllerBase
{
    private const string ConnectionString = """
        Server=(localdb)\MSSQLLocalDB;Database=DAYR_PWA_QUOTE_DEV;Integrated Security=True;
        Encrypt=True;TrustServerCertificate=True;Connect Timeout=5;
        """;

    [HttpGet("clients")]
    public Task<ActionResult<CatalogPage<ClientItem>>> Clients(
        [FromQuery, StringLength(30)] string? after, [FromQuery, Range(1, 100)] int limit = 50,
        CancellationToken cancellationToken = default) =>
        Read(null, false, after, limit, row => new ClientItem(row.GetString(0), row.GetString(1)), cancellationToken);

    [HttpGet("products")]
    public Task<ActionResult<CatalogPage<ProductItem>>> Products(
        [FromQuery, StringLength(30)] string? after, [FromQuery, Range(1, 100)] int limit = 50,
        CancellationToken cancellationToken = default) =>
        Read(null, true, after, limit, row => new ProductItem(
            row.GetString(0), row.GetString(1), row.GetString(2), row.GetBoolean(3)), cancellationToken);

    [HttpGet("clients/{clientCode}/prices")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound)]
    public Task<ActionResult<CatalogPage<PriceItem>>> Prices(
        [StringLength(30)] string clientCode, [FromQuery, StringLength(30)] string? after,
        [FromQuery, Range(1, 100)] int limit = 50, CancellationToken cancellationToken = default) =>
        Read(clientCode, false, after, limit, row => new PriceItem(
            row.GetString(0), row.GetString(1), row.GetString(2), row.GetBoolean(3),
            row.GetString(4), row.GetString(5), row.GetDecimal(6).ToString("F4", CultureInfo.InvariantCulture),
            row.GetString(7), AsUtc(row.GetDateTime(8)),
            row.IsDBNull(9) ? null : AsUtc(row.GetDateTime(9)), AsUtc(row.GetDateTime(10))),
            cancellationToken);

    private async Task<ActionResult<CatalogPage<T>>> Read<T>(
        string? client, bool products, string? after, int limit, Func<DbDataReader, T> map,
        CancellationToken cancellationToken)
    {
        var issuer = User.FindFirst("iss")?.Value;
        var subject = User.FindFirst("sub")?.Value;
        if (string.IsNullOrWhiteSpace(issuer) || issuer.Length > 200 ||
            string.IsNullOrWhiteSpace(subject) || subject.Length > 200)
            return Forbid();

        if (!ValidCode(client) || !ValidCode(after))
            return Problem(statusCode: 400, title: "Código o cursor inválido");

        var results = new List<T>();
        string? lastCode = null;
        var codes = 0;
        try
        {
            await using var connection = new SqlConnection(ConnectionString);
            await using var command = new SqlCommand("dbo.LeerCatalogoCotizacion", connection)
            {
                CommandType = CommandType.StoredProcedure,
                CommandTimeout = 10
            };
            command.Parameters.Add("@Emisor", SqlDbType.NVarChar, 200).Value = issuer;
            command.Parameters.Add("@Sujeto", SqlDbType.NVarChar, 200).Value = subject;
            command.Parameters.Add("@CodigoCliente", SqlDbType.VarChar, 30).Value = (object?)client ?? DBNull.Value;
            command.Parameters.Add("@DespuesDe", SqlDbType.VarChar, 30).Value = (object?)after ?? DBNull.Value;
            command.Parameters.Add("@Limite", SqlDbType.Int).Value = limit + 1;
            command.Parameters.Add("@SoloProductos", SqlDbType.Bit).Value = products;

            await connection.OpenAsync(cancellationToken);
            await using var reader = await command.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                var code = reader.GetString(0);
                if (code != lastCode)
                {
                    if (++codes > limit)
                        return Ok(new CatalogPage<T>(results, lastCode));
                    lastCode = code;
                }

                results.Add(map(reader));
            }
        }
        catch (SqlException error) when (error.Number is 51002 or 51003)
        {
            return error.Number == 51002 ? Forbid() : NotFound();
        }
        catch (SqlException error) when (!cancellationToken.IsCancellationRequested)
        {
            HttpContext.RequestServices.GetRequiredService<ILogger<QuoteCatalogController>>()
                .LogError("Error SQL {Number} al consultar el catálogo. TraceId: {TraceId}",
                    error.Number, HttpContext.TraceIdentifier);
            return Problem(statusCode: 503, title: "Catálogo temporalmente indisponible");
        }

        return Ok(new CatalogPage<T>(results, null));
    }

    private static bool ValidCode(string? code) => code is null ||
        (code.Length is >= 1 and <= 30 && code == code.Trim() && !code.Any(char.IsControl));

    private static DateTime AsUtc(DateTime value) => DateTime.SpecifyKind(value, DateTimeKind.Utc);
}

public sealed record CatalogPage<T>(IReadOnlyList<T> Items, string? NextCursor)
{
    public bool StockValidationEnabled => false;

    // Synthetic development catalog. The schema has no per-product tax classification.
    public string NetPriceTaxRate => "0.1800";
}

public sealed record ClientItem(string Code, string Name);
public sealed record ProductItem(string Code, string Description, string Unit, bool AllowsFraction);
public sealed record PriceItem(string ProductCode, string Description, string Unit, bool AllowsFraction,
    string PriceList, string Currency, string NetUnitPrice, string SourceVersion, DateTime ValidFromUtc,
    DateTime? ValidUntilUtc, DateTime ReadAtUtc);
