var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Load appsettings.json
builder.Configuration.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);

// Ensure wwwroot exists before the app starts
var webRootPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");

if (!Directory.Exists(webRootPath))
{
    Directory.CreateDirectory(webRootPath);
    Console.WriteLine("wwwroot directory created.");
}

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
