using Microsoft.EntityFrameworkCore;
using SalesApp.Data;
using SalesApp.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register services
builder.Services.AddScoped<ICustomerService, CustomerService>();
builder.Services.AddScoped<IProductService, ProductService>();



// Load appsettings.json
//builder.Configuration.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);

// Ensure wwwroot exists before the app starts
var webRootPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");

if (!Directory.Exists(webRootPath))
{
    Directory.CreateDirectory(webRootPath);
    Console.WriteLine("wwwroot directory created.");
}

// Configure EF Core with SQL Server
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

// Enable Swagger in Development & Production
if (app.Environment.IsDevelopment() || app.Environment.IsProduction())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Ensure HTTPS redirection works
if (!app.Environment.IsDevelopment()) 
{
    app.UseHttpsRedirection();
}

// Ensure static files (wwwroot) can be served
app.UseStaticFiles(); 

app.UseAuthorization();
app.MapControllers();


app.Run();
