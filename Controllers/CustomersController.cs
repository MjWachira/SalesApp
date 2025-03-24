using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

[ApiController]
[Route("api/customers")]
public class CustomersController : ControllerBase
{
    private readonly IWebHostEnvironment _env;

    public CustomersController(IWebHostEnvironment env)
    {
        _env = env;
    }

    [HttpGet]
    public IActionResult GetCustomers()
    {
        var filePath = Path.Combine(_env.ContentRootPath, "customers.json");

        if (!System.IO.File.Exists(filePath))
        {
            return NotFound("Customers data file not found.");
        }

        var jsonData = System.IO.File.ReadAllText(filePath);
        var customers = JsonSerializer.Deserialize<object>(jsonData);

        return Ok(customers);
    }
}
