using Backend.Contracts;

namespace Backend.Services;

/// <summary>Datos deterministas de prueba. No consulta ni modifica ningún ERP.</summary>
public sealed class SyntheticProductCatalog : IProductCatalog
{
    private static readonly IReadOnlyList<ProductResponse> Products = Array.AsReadOnly<ProductResponse>(
    [
        new("test-product-001", "TEST-001", "999000000001", "PRODUCTO FICTICIO A", "PRUEBA", "UND", "TEST-A1", "TEST-E1", 10m, null, 1.18m, null, null),
        new("test-product-002", "TEST-002", "999000000002", "PRODUCTO FICTICIO B", "PRUEBA", "UND", "TEST-A1", "TEST-E2", 25m, null, 5.90m, null, null),
        new("test-product-003", "TEST-003", "999000000003", "PRODUCTO FICTICIO C", "PRUEBA", "UND", "TEST-A2", "TEST-E1", 0m, null, 11.80m, null, null)
    ]);

    public IReadOnlyList<ProductResponse> GetProducts() => Products;
}
