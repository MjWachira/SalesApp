using SalesApp.Models;

namespace SalesApp.Services
{
    public interface IProductService
    {
        Task<List<Product>> GetProductsAsync();
        Task AddProductAsync(Product product);
    }
}
