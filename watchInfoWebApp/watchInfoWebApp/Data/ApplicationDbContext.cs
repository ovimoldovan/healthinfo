using System;
using Microsoft.EntityFrameworkCore;
using watchInfoWebApp.Models;

namespace watchInfoWebApp.Data
{
    public class ApplicationDbContext : DbContext
    {
        public DbSet<User> Users { get; set; }
        public DbSet<DataItem> DataItems { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder options)
                   => options.UseSqlite("Data Source=watchInfo.db");
    }
}
