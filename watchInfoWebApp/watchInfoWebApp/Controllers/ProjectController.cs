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
    [Authorize]
    [ApiController]
    [Route("Api/[controller]")]
    public class ProjectController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        private readonly ILogger<DataItemController> _logger;

        private ClaimsGetter claimsGetter = new ClaimsGetter();

        public ProjectController(ILogger<DataItemController> logger, ApplicationDbContext context)
        {
            _logger = logger;
            _context = context;
            if (_context.Projects.Count() == 0)
            {
                _context.Projects.Add(new Project
                {
                    Id = 1,
                    Name = "No Project"
                });
                _context.SaveChanges();
            }
        }

        [HttpPost("newProject")]
        public async Task<ActionResult<Project>> CreateProject(Project project)
        {

            var userId = claimsGetter.UserId(User?.Claims);
            project.CreatedByUserId = userId;
            project.StartTime = DateTime.Now;
            _context.Projects.Add(project);
            await _context.SaveChangesAsync();


            return Ok();
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Project>> GetProject(int id)
        {
            var project = await _context.Projects.FindAsync(id);

            if (project == null)
            {
                return NotFound();
            }

            return project;
        }

        [HttpGet("createdByMe")]
        public async Task<ActionResult<List<Project>>> GetMyProjects()
        {
            var projects = new List<Project>();
            var userId = claimsGetter.UserId(User?.Claims);

            projects = await _context.Projects.Where(x => x.CreatedByUserId == userId).ToListAsync();
            
            return projects;
        }

        [HttpGet("currentProject")]
        public async Task<ActionResult<Project>> GetCurrentProject()
        {
            var project = new Project();
            var userId = claimsGetter.UserId(User?.Claims);
            var projectId = _context.Users.Where(x => x.Id == userId).Select(x => x.ProjectId);

            project = await _context.Projects.SingleOrDefaultAsync(x => x.Id == projectId.First());

            return project;
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("getAllData")]
        public async Task<ActionResult<List<Project>>> GetAllProjects()
        {
            var projects = new List<Project>();
            //var userId = claimsGetter.UserId(User?.Claims);

            projects = await _context.Projects.ToListAsync();

            return projects;
        }
    }
}

