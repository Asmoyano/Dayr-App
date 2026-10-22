using Backend.Contracts;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[ApiController]
[Route("health")]
[Produces("application/json")]
public sealed class HealthController(IWebHostEnvironment environment, IConfiguration configuration) : ControllerBase
{
    /// <summary>Confirma que el proceso responde; no verifica dependencias empresariales.</summary>
    [HttpGet(Name = "GetHealth")]
    [ProducesResponseType<HealthResponse>(StatusCodes.Status200OK)]
    public HealthResponse Get() => new("Healthy", "dayr-api", DateTimeOffset.UtcNow, "Process",
        environment.IsDevelopment() && configuration.GetValue<bool>("SyntheticCatalog:Enabled")
            ? "Synthetic" : "None");
}
