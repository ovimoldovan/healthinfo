using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using watchInfoWebApp.Data;
using watchInfoWebApp.Models;
using watchInfoWebApp.ViewModels;

namespace watchInfoWebApp.Controllers
{
        [ApiController]
        [Route("Api/[controller]")]
        public class UserController : ControllerBase
        {
            private readonly ApplicationDbContext _context;

            private readonly ILogger<UserController> _logger;

            public UserController(ILogger<UserController> logger, ApplicationDbContext context)
            {
                _logger = logger;
                _context = context;
                if (_context.Users.Count() == 0)
                {
                    _context.Users.Add(new User { Username = "admin", Password = "admin" });
                    _context.SaveChanges();
                }
            }


            [HttpPost]
            public async Task<ActionResult<User>> CreateUser(User user)
            {
                _context.Users.Add(user);
                await _context.SaveChangesAsync();

                return CreatedAtAction(nameof(GetUser), new { username = user.Username }, user);
            }

            [HttpGet("{id}")]
            public async Task<ActionResult<User>> GetUser(long id)
            {
                var user = await _context.Users.FindAsync(id);

                if (user == null)
                {
                    return NotFound();
                }

                return user;
            }


        [HttpPost("login")]
        public async Task<IActionResult> GetUserLogin(User request)
        {
            var foundUser = await _context.Users.FirstOrDefaultAsync(user => user.Username == request.Username && user.Password == request.Password);

            if (foundUser == null)
            {
                return BadRequest(new { message = "Email or password incorrect" });
            }

            LoginViewModel loginViewModel = new LoginViewModel
            {
                Username = foundUser.Username,
                Name = foundUser.Name
            };

            return Ok(loginViewModel);
        }
        }
    }
