using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using watchInfoWebApp.Data;
using watchInfoWebApp.Models;
using watchInfoWebApp.Tools;

namespace watchInfoWebApp.Controllers
{
    [ApiController]
    [Route("Api/[controller]")]
    public class DataItemController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        private readonly ILogger<DataItemController> _logger;

        private ClaimsGetter claimsGetter = new ClaimsGetter();

        public DataItemController(ILogger<DataItemController> logger, ApplicationDbContext context)
        {
            _logger = logger;
            _context = context;
            if (_context.DataItems.Count() == 0)
            {
                _context.DataItems.Add(new DataItem
                {
                    HeartBpm = 80,
                    //User = context.Users.FirstOrDefault( x => x.Id == 1)
                });
                _context.SaveChanges();
            }
        }

        [Authorize]
        [HttpPost]
        public async Task<ActionResult<DataItem>> PostDataItem(DataItem healthDataItem)
        {

            var userId = claimsGetter.UserId(User?.Claims);
            healthDataItem.UserId = userId;
            healthDataItem.SentDate = DateTime.Now;
            _context.DataItems.Add(healthDataItem);
            await _context.SaveChangesAsync();

            

            return CreatedAtAction(nameof(GetDataItem), new
            {
                heartBpm = healthDataItem.HeartBpm,
                healthDataItem
            });
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

        [Authorize]
        [HttpGet]
        public async Task<ActionResult<List<DataItem>>> GetMyDataItems()
        {
            var healthDataItems = new List<DataItem>();
            var userId = claimsGetter.UserId(User?.Claims);

            healthDataItems = await _context.DataItems.Where(x => x.UserId == userId).ToListAsync();
            
            return healthDataItems;
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("getAllData")]
        public async Task<ActionResult<List<DataItem>>> GetAllDataItems()
        {
            var healthDataItems = new List<DataItem>();
            //var userId = claimsGetter.UserId(User?.Claims);

            healthDataItems = await _context.DataItems.ToListAsync();

            return healthDataItems;
        }
    }
}

