using System.Net;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;

namespace Backend.Authentication;

internal sealed class DevQuoteAuthentication(
    IOptionsMonitor<AuthenticationSchemeOptions> options, ILoggerFactory logger, UrlEncoder encoder,
    IWebHostEnvironment environment, IConfiguration configuration)
    : AuthenticationHandler<AuthenticationSchemeOptions>(options, logger, encoder)
{
    public const string SchemeName = "DayrQuoteDevelopment";

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        if (!environment.IsDevelopment() || !configuration.GetValue<bool>("QuoteCatalog:Enabled")
            || !Request.IsHttps || Context.Connection.RemoteIpAddress is not { } address
            || !IPAddress.IsLoopback(address))
            return Task.FromResult(AuthenticateResult.NoResult());

        var header = Request.Headers.Authorization.ToString();
        if (!header.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase) || header.Length != 71)
            return Task.FromResult(AuthenticateResult.NoResult());

        var supplied = Encoding.ASCII.GetBytes(header[7..]);
        var first = configuration["QuoteCatalog:Seller1Token"];
        var second = configuration["QuoteCatalog:Seller2Token"];
        if (!Valid(first) || !Valid(second) || first == second)
            return Task.FromResult(AuthenticateResult.Fail("Development credentials unavailable."));

        var seller = Matches(first!, supplied) ? "vendedor-1" : Matches(second!, supplied) ? "vendedor-2" : null;
        if (seller is null)
            return Task.FromResult(AuthenticateResult.Fail("Invalid bearer credential."));

        var identity = new ClaimsIdentity([
            new Claim("iss", "urn:dayr:synthetic:untrusted"),
            new Claim("sub", seller)
        ], SchemeName);
        return Task.FromResult(AuthenticateResult.Success(new AuthenticationTicket(new ClaimsPrincipal(identity), SchemeName)));
    }

    private static bool Valid(string? token) => token is { Length: 64 } && token.All(c => c is >= '0' and <= '9' or >= 'a' and <= 'f');

    private static bool Matches(string expected, byte[] supplied) =>
        CryptographicOperations.FixedTimeEquals(Encoding.ASCII.GetBytes(expected), supplied);
}
