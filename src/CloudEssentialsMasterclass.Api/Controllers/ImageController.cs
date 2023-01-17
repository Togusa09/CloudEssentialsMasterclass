using Azure.Storage.Blobs;
using Microsoft.AspNetCore.Mvc;

namespace CloudEssentialsMasterclass.Api.Controllers
{
    [Route("[controller]")]
    public class ImageController : Controller
    {
        private readonly IConfiguration _configuration;

        public ImageController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpPost]
        public IActionResult Upload([FromForm] IFormFile file)
        {
            string name = file.FileName;
            string extension = Path.GetExtension(file.FileName);
            //read the file
            using (var memoryStream = new MemoryStream())
            {
                file.CopyTo(memoryStream);
            }

            var blobConnectionString = _configuration["AzureWebJobsStorage"];

            var newFilename = Guid.NewGuid().ToString() + "." + extension;

            BlobContainerClient container = new BlobContainerClient(blobConnectionString, );
            BlobClient blob = container.GetBlobClient(newFilename);

            return Ok();
        }

        public IActionResult GetImage()
        {
            return Ok();
        }
    }
}
