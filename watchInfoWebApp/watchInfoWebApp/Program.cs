using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;

namespace watchInfoWebApp
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                    //webBuilder.UseUrls("http://localhost:5000", "http://192.168.0.111:5000");
                    webBuilder.UseUrls("http://localhost:5000", "http://192.168.1.3:5000");
                    //webBuilder.UseUrls("http://localhost:")
                });
    }
}
