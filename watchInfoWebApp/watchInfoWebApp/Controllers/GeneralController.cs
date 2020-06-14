using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace watchInfoWebApp.Controllers
{
    [ApiController]
    [Route("Api/[controller]")]
    public class GeneralController
    {
        [HttpGet("hour")]
        public async Task<ActionResult<DateTime>> GetTime()
        {
            return DateTime.Now;
        }
    }
}
