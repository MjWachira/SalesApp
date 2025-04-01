using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SalesApp.DTO;
using SalesApp.Models;
using SalesApp.Services;

[ApiController]
[Route("api/customers")]
public class CustomersController : ControllerBase
{
    private readonly ICustomerService _customerService;

    public CustomersController(ICustomerService customerService)
    {
        _customerService = customerService;
    }

    [HttpGet("all")]
    public async Task<IActionResult> GetCustomers()
    {
        var customerDtos = await _customerService.GetCustomersAsync();
        return Ok(customerDtos);
    }

    [HttpPost]
    public async Task<IActionResult> AddCustomer([FromBody] CustomerDto customerDto)
    {
        // Use the service to add the customer
        var customer = await _customerService.AddCustomerAsync(customerDto.Name, customerDto.Email);

        return CreatedAtAction(nameof(GetCustomers), new { id = customer.Id }, customer);
    }

    [HttpPost("{customerId}/{productId}")]
    public async Task<IActionResult> AddProductToCustomer(int customerId, int productId)
    {
        try
        {
            await _customerService.AddProductToCustomerAsync(customerId, productId);
            return Ok(new { message = "Product added to customer" });
        }
        catch (ArgumentException ex)
        {
            return NotFound(ex.Message);
        }
    }
}
