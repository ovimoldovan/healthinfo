using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using webApp.Data;
using webApp.Models;

namespace webApp.Controllers
{
    [ApiController]
    [Route("Api/[controller]")]
    public class HealthDataItemController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        private readonly ILogger<WeatherForecastController> _logger;

        public HealthDataItemController(ILogger<WeatherForecastController> logger, ApplicationDbContext context)
        {
            _logger = logger;
            _context = context;
            if (_context.HealthDataItems.Count() == 0)
            {
                _context.HealthDataItems.Add(new HealthDataItem { HeartBpm = 80 });
                _context.SaveChanges();
            }
        }

        
        [HttpPost]
        public async Task<ActionResult<HealthDataItem>> PostTodoItem(HealthDataItem healthDataItem)
        {
            _context.HealthDataItems.Add(healthDataItem);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetHealthDataItem), new { heartBpm = healthDataItem.HeartBpm }, healthDataItem);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<HealthDataItem>> GetHealthDataItem(long id)
        {
            var healthDataItem = await _context.HealthDataItems.FindAsync(id);

            if (healthDataItem == null)
            {
                return NotFound();
            }

            return healthDataItem;
        }
    }
}
