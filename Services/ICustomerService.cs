using SalesApp.DTO;
using SalesApp.Models;

namespace SalesApp.Services
{
    public interface ICustomerService
    {
        Task<List<AddCustomerDto>> GetCustomersAsync();
        Task<Customer> AddCustomerAsync(string name, string email);
        Task AddProductToCustomerAsync(int customerId, int productId);
    }
}
