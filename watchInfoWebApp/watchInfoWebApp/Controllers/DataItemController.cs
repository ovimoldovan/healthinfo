using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using watchInfoWebApp.Data;
using watchInfoWebApp.Models;

namespace watchInfoWebApp.Controllers
{
        [ApiController]
        [Route("Api/[controller]")]
        public class DataItemController : ControllerBase
        {
            private readonly ApplicationDbContext _context;

            private readonly ILogger<DataItemController> _logger;

            public DataItemController(ILogger<DataItemController> logger, ApplicationDbContext context)
            {
                _logger = logger;
                _context = context;
                if (_context.DataItems.Count() == 0)
                {
                    _context.DataItems.Add(new DataItem {
                        HeartBpm = 80,
                        //User = context.Users.FirstOrDefault( x => x.Id == 1)
                    });
                    _context.SaveChanges();
                }
            }


            [HttpPost]
            public async Task<ActionResult<DataItem>> PostDataItem(DataItem healthDataItem)
            {
                _context.DataItems.Add(healthDataItem);
                await _context.SaveChangesAsync();

                return CreatedAtAction(nameof(GetDataItem), new { heartBpm = healthDataItem.HeartBpm }, healthDataItem);
            }

            [HttpGet("{id}")]
            public async Task<ActionResult<DataItem>> GetDataItem(long id)
            {
                var healthDataItem = await _context.DataItems.FindAsync(id);

                if (healthDataItem == null)
                {
                    return NotFound();
                }

                return healthDataItem;
            }
        }
    }

