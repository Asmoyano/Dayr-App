using Backend.Contracts;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[ApiController]
[Route("v1/inventory/products")]
public sealed class InventoryController(
    IProductCatalog catalog,
    IWebHostEnvironment environment,
    IConfiguration configuration) : ControllerBase
{
    /// <summary>Catálogo ficticio de solo lectura, exclusivo de Development.</summary>
    [HttpGet(Name = "GetInventoryProducts")]
    [ProducesResponseType<ProductResponse[]>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound)]
    public ActionResult<IReadOnlyList<ProductResponse>> Get()
    {
        if (!environment.IsDevelopment() || !configuration.GetValue<bool>("SyntheticCatalog:Enabled"))
        {
            return Problem(statusCode: StatusCodes.Status404NotFound, title: "Recurso no disponible");
        }

        return Ok(catalog.GetProducts());
    }
}
