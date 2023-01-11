
using System.Reflection;
using DbUp;
using Microsoft.Extensions.Configuration;

namespace CloudEssentialsMasterclass.DbUp // Note: actual namespace depends on the project name.
{
    internal class Program
    {
        static int Main(string[] args)
        {
            var env = Environment.GetEnvironmentVariable("DOTNET_ENVIRONMENT");

            // var configuration = new ConfigurationBuilder()
            //     .SetBasePath(Directory.GetCurrentDirectory())
            //     .AddJsonFile("appsettings.json")
            //     .AddJsonFile($"appsettings.{env}.json", true)
            //     .AddEnvironmentVariables()
            //     .Build();
            
            // var connectionString = configuration.GetConnectionString("DefaultConnection");
            
            var connectionString =
                args.FirstOrDefault()
                ?? "Server=.;Database=AzureMasterclass; Trusted_connection=true;MultipleActiveResultSets=true;TrustServerCertificate=True";
            
            var upgrader =
                DeployChanges.To
                    .SqlDatabase(connectionString)
                    .WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly())
                    .LogToConsole()
                    .Build();

            var result = upgrader.PerformUpgrade();

            if (!result.Successful)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine(result.Error);
                Console.ResetColor();
#if DEBUG
                Console.ReadLine();
#endif
                return -1;
            }

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("Success!");
            Console.ResetColor();
            return 0;
        }
    }
}