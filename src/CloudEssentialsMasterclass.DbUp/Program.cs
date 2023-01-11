
using System.Reflection;
using DbUp;
using Microsoft.Extensions.Configuration;

namespace CloudEssentialsMasterclass.DbUp // Note: actual namespace depends on the project name.
{
    internal class Program
    {
        static int Main(string[] args)
        {   
            var connectionString = GetConnectionString(args);
            
            var upgrader =DeployChanges.To
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

        private static string GetConnectionString(string[] args) {
            var env = Environment.GetEnvironmentVariable("DOTNET_ENVIRONMENT");
            var isDev = env == "Development";
            
            if (isDev) {
                // TODO: I'm not sure why, but appsettings.json is not being found 
                // when the "Run database migrations" task in azure-pipeline.yml by the pipeline.
                // This is a temporary work around so I'm not blocked by it.
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .AddJsonFile($"appsettings.{env}.json", true)
                    .AddEnvironmentVariables()
                    .Build();
                var connectionString = configuration.GetConnectionString("DefaultConnection");
                return connectionString!;
            } else {
                var connectionString =
                    args.FirstOrDefault()
                        ?? "Server=.;Database=AzureMasterclass; Trusted_connection=true;MultipleActiveResultSets=true;TrustServerCertificate=True";
                return connectionString;
            }
        }
    }
}