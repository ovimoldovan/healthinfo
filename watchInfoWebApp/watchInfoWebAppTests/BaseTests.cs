using System;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using watchInfoWebApp.Data;

namespace watchInfoWebAppTests
{
    public class BaseTests
    {
        protected SqliteConnection sqliteConnection;
        protected ApplicationDbContext dbContext;

        public BaseTests()
        {
            // Build service colection to create identity UserManager and RoleManager. 
            IServiceCollection serviceCollection = new ServiceCollection();

            // Add ASP.NET Core Identity database in memory.
            sqliteConnection = new SqliteConnection("DataSource=:memory:");
            serviceCollection.AddOptions();
            serviceCollection.AddDbContext<ApplicationDbContext>();


            dbContext = serviceCollection.BuildServiceProvider().GetService<ApplicationDbContext>();

            dbContext.Database.OpenConnection();
            dbContext.Database.EnsureCreated();

        }

        public void Dispose()
        {
            dbContext.Database.EnsureDeleted();
            dbContext.Dispose();
            sqliteConnection.Close();
        }
    }
}
