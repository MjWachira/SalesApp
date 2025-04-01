using Microsoft.EntityFrameworkCore;
using SalesApp.Data;
using SalesApp.DTO;
using SalesApp.Models;
using SalesApp.Services;

public class CustomerService : ICustomerService
{
    private readonly AppDbContext _context;

    public CustomerService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<AddCustomerDto>> GetCustomersAsync()
    {
        var customers = await _context.Customers
            .Include(c => c.CustomerProducts)
            .ThenInclude(cp => cp.Product)
            .ToListAsync();

        var customerDtos = customers.Select(c => new AddCustomerDto
        {
            Id = c.Id,
            Name = c.Name,
            Email = c.Email,
            Products = c.CustomerProducts.Select(cp => new ProductDto
            {
                Id = cp.Product.Id,
                Name = cp.Product.Name
            }).ToList()
        }).ToList();

        return customerDtos;
    }

    public async Task<Customer> AddCustomerAsync(string name, string email)
    {
        // Create a new Customer entity
        var customer = new Customer
        {
            Name = name,
            Email = email
        };

        _context.Customers.Add(customer);
        await _context.SaveChangesAsync();
        return customer;
    }

    public async Task AddProductToCustomerAsync(int customerId, int productId)
    {
        var customer = await _context.Customers.FindAsync(customerId);
        var product = await _context.Products.FindAsync(productId);

        if (customer == null || product == null)
            throw new ArgumentException("Customer or Product not found");

        var customerProduct = new CustomerProduct { CustomerId = customerId, ProductId = productId };
        _context.CustomerProducts.Add(customerProduct);
        await _context.SaveChangesAsync();
    }
}
