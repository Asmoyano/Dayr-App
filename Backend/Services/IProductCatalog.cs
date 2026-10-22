using Backend.Contracts;

namespace Backend.Services;

public interface IProductCatalog
{
    IReadOnlyList<ProductResponse> GetProducts();
}
