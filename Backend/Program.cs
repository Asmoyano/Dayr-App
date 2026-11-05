using System.Diagnostics;
using Backend.Services;
using Backend.Authentication;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.OpenApi;

var builder = WebApplication.CreateBuilder(args);

const string corsPolicy = "LocalFrontend";
var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
foreach (var origin in allowedOrigins)
{
    if (origin.Contains('*') || !Uri.TryCreate(origin, UriKind.Absolute, out var uri)
        || (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps)
        || !string.IsNullOrEmpty(uri.UserInfo)
        || origin != uri.GetLeftPart(UriPartial.Authority)
        || (!builder.Environment.IsDevelopment() && uri.Scheme != Uri.UriSchemeHttps))
    {
        throw new InvalidOperationException("Cors:AllowedOrigins debe contener orígenes HTTP(S) exactos, sin rutas ni comodines; fuera de Development se exige HTTPS.");
    }
}

if (!builder.Environment.IsDevelopment()
    && builder.Configuration.GetValue<bool>("SyntheticCatalog:Enabled"))
{
    throw new InvalidOperationException("El catálogo sintético solo puede habilitarse en Development.");
}

builder.Services.AddCors(options => options.AddPolicy(corsPolicy, policy => policy
    .WithOrigins(allowedOrigins)
    .WithMethods(HttpMethods.Get)
    .WithHeaders("Content-Type", "Authorization")
    .WithExposedHeaders("X-Correlation-ID")));
builder.Services.AddHttpsRedirection(options =>
    options.HttpsPort = builder.Configuration.GetValue<int?>("HttpsRedirection:HttpsPort"));
builder.Services.AddAuthentication()
    .AddScheme<AuthenticationSchemeOptions, DevQuoteAuthentication>(DevQuoteAuthentication.SchemeName, _ => { });
builder.Services.AddAuthorizationBuilder().AddPolicy("DayrQuoteCatalog", policy => policy
    .AddAuthenticationSchemes(DevQuoteAuthentication.SchemeName).RequireAuthenticatedUser());
builder.Services.AddControllers();
builder.Services.AddOpenApi(options => options.AddDocumentTransformer((document, _, _) =>
{
    const string scheme = "DayrQuoteBearer";
    document.Components ??= new OpenApiComponents();
    document.Components.SecuritySchemes ??= new Dictionary<string, IOpenApiSecurityScheme>();
    document.Components.SecuritySchemes[scheme] = new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        Description = "Token local del vendedor para Development."
    };

    foreach (var path in document.Paths.Where(path => path.Key.StartsWith("/v1/quote-catalog/", StringComparison.Ordinal)))
    foreach (var operation in path.Value.Operations!.Values)
    {
        operation.Security = [new OpenApiSecurityRequirement
        {
            [new OpenApiSecuritySchemeReference(scheme, document)] = []
        }];
    }

    return Task.CompletedTask;
}));
builder.Services.AddProblemDetails(options => options.CustomizeProblemDetails = context =>
    context.ProblemDetails.Extensions["traceId"] = context.HttpContext.TraceIdentifier);
builder.Services.AddSingleton<IProductCatalog, SyntheticProductCatalog>();

var app = builder.Build();

app.Use(async (context, next) =>
{
    var started = Stopwatch.GetTimestamp();
    context.Response.OnStarting(() =>
    {
        context.Response.Headers["X-Correlation-ID"] = context.TraceIdentifier;
        context.Response.Headers.CacheControl = "no-store";
        return Task.CompletedTask;
    });
    try
    {
        await next(context);
    }
    finally
    {
        app.Logger.LogInformation("HTTP {Method} {Path} respondió {StatusCode} en {ElapsedMs} ms. TraceId: {TraceId}",
            context.Request.Method, context.Request.Path, context.Response.StatusCode,
            Stopwatch.GetElapsedTime(started).TotalMilliseconds, context.TraceIdentifier);
    }
});

// Respuestas públicas estructuradas, sin detalles de excepciones ni secretos.
app.UseExceptionHandler(errorApp => errorApp.Run(async context =>
    await Results.Problem(statusCode: StatusCodes.Status500InternalServerError,
        title: "Error interno del servicio",
        extensions: new Dictionary<string, object?> { ["traceId"] = context.TraceIdentifier })
        .ExecuteAsync(context)));
app.UseStatusCodePages(async statusContext =>
{
    var context = statusContext.HttpContext;
    var status = context.Response.StatusCode;
    await Results.Problem(statusCode: status, title: ReasonPhrases.GetReasonPhrase(status),
        extensions: new Dictionary<string, object?> { ["traceId"] = context.TraceIdentifier })
        .ExecuteAsync(context);
});

app.UseHttpsRedirection();
app.UseRouting();
app.UseCors(corsPolicy);
app.UseAuthentication();
app.UseAuthorization();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.MapControllers();
app.Run();
