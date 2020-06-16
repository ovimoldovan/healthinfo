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
                });
                _context.SaveChanges();
            }
        }

        [Authorize]
        [HttpPost]
        public async Task<ActionResult<DataItem>> PostDataItem(DataItem healthDataItem)
        {

            var userId = claimsGetter.UserId(User?.Claims);
            var projectId = _context.Users.Where(x => x.Id == userId).Select(x => x.ProjectId).FirstOrDefault();
            healthDataItem.UserId = userId;
            healthDataItem.SentDate = DateTime.Now;
            healthDataItem.ProjectId = projectId;
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

        [Authorize]
        [HttpDelete("{id}")]
        public async Task<ActionResult<List<DataItem>>> DeleteMyDataItem(long id)
        {
            var healthDataItem = new DataItem();
            var userId = claimsGetter.UserId(User?.Claims);
            var userRole = claimsGetter.UserRole(User?.Claims);

            //The user can delete only his data unless he is admin
            healthDataItem = await _context.DataItems.Where(x => x.Id == id && (x.UserId == userId || userRole == "Admin")).FirstOrDefaultAsync();

            if(healthDataItem != null)
            {
                _context.DataItems.Remove(healthDataItem);
                await _context.SaveChangesAsync();
            }

            return NoContent();
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

        [HttpGet("getProjectData/{id}")]
        public async Task<ActionResult<List<DataItemJoinDto>>> GetProjectDataItem(long id)
        {
            //var healthDataItems = new List<DataItem>();

            //var healthDataItems = _context.DataItems
            //    .FromSqlRaw("SELECT DataItems.Id, HeartBpm, Device, Distance, Steps, SentDate, GpsCoordinates, UserId, UserId1, ProjectId FROM DataItems JOIN Projects ON DataItems.ProjectId = Projects.Id WHERE DataItems.ProjectId = {0}", id)
            //    .AsNoTracking()
            //    .ToList();

            var healthDataItems = from dataItem in _context.DataItems
                                  join project in _context.Projects
                                    on dataItem.ProjectId equals project.Id into DataItemJoinDto
                                    from defaultValue in DataItemJoinDto.DefaultIfEmpty()
                                  where dataItem.ProjectId == id
                                 select new DataItemJoinDto
                                 {
                                     Id = dataItem.Id,
                                     UserId = dataItem.UserId,
                                     HeartBpm = dataItem.HeartBpm,
                                     GpsCoordinates = dataItem.GpsCoordinates,
                                     Steps = dataItem.Steps,
                                     Distance = dataItem.Distance,
                                     SentDate = dataItem.SentDate,
                                     Device = dataItem.Device,
                                     ProjectId = dataItem.ProjectId,
                                     ProjectName = defaultValue.Name
                                 };


            return await healthDataItems.ToListAsync();
        }

        [HttpGet("getProjectDataWithUser/{id}")]
        public async Task<ActionResult<DataItemWithUserDto>> GetProjectDataItemWithUser(long id)
        {

            var healthDataItems = from dataItem in _context.DataItems
                                  join user in _context.Users
                                    on dataItem.UserId equals user.Id into DataItemWithUserDto
                                  from defaultValue in DataItemWithUserDto.DefaultIfEmpty()
                                  where dataItem.Id == id
                                  select new DataItemWithUserDto
                                  {
                                      Id = dataItem.Id,
                                      UserId = dataItem.UserId,
                                      HeartBpm = dataItem.HeartBpm,
                                      GpsCoordinates = dataItem.GpsCoordinates,
                                      Steps = dataItem.Steps,
                                      Distance = dataItem.Distance,
                                      SentDate = dataItem.SentDate,
                                      Device = dataItem.Device,
                                      Name = defaultValue.Name
                                  };


            return await healthDataItems.FirstOrDefaultAsync();
        }
    }


    public class DataItemJoinDto
    {
        public long Id { get; set; }
        public int UserId { get; set; }
        public int HeartBpm { get; set; }
        public string GpsCoordinates { get; set; }
        public int Steps { get; set; }
        public double Distance { get; set; }
        public DateTime SentDate { get; set; }
        public string Device { get; set; }
        public int ProjectId { get; set; }
        public string ProjectName { get; set; }

    }

    public class DataItemWithUserDto
    {
        public long Id { get; set; }
        public string Name { get; set; }
        public int UserId { get; set; }
        public int HeartBpm { get; set; }
        public string GpsCoordinates { get; set; }
        public int Steps { get; set; }
        public double Distance { get; set; }
        public DateTime SentDate { get; set; }
        public string Device { get; set; }
    }
}

