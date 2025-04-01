using Microsoft.EntityFrameworkCore;
using SalesApp.Models;

namespace SalesApp.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Customer> Customers { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<CustomerProduct> CustomerProducts { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.HasDefaultSchema("sls");

            modelBuilder.Entity<CustomerProduct>()
                .HasKey(cp => new { cp.CustomerId, cp.ProductId });

            modelBuilder.Entity<CustomerProduct>()
                .HasOne(cp => cp.Customer)
                .WithMany(c => c.CustomerProducts)
                .HasForeignKey(cp => cp.CustomerId);

            modelBuilder.Entity<CustomerProduct>()
                .HasOne(cp => cp.Product);

            // Seed Customers
            modelBuilder.Entity<Customer>().HasData(
                new Customer { Id = 1, Name = "Alice Johnson", Email = "alice@example.com" },
                new Customer { Id = 2, Name = "Bob Smith", Email = "bob@example.com" }
            );

            // Seed Products
            modelBuilder.Entity<Product>().HasData(
                new Product { Id = 1, Name = "TV" },
                new Product { Id = 2, Name = "Radio" },
                new Product { Id = 3, Name = "Laptop" }
            );

            // Seed Customer-Product Relationships (Alice owns TV and Radio)
            modelBuilder.Entity<CustomerProduct>().HasData(
                new CustomerProduct { CustomerId = 1, ProductId = 1 }, // Alice -> TV
                new CustomerProduct { CustomerId = 1, ProductId = 2 }  // Alice -> Radio
            );
        }

    }
}
