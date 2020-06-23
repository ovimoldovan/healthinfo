using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using watchInfoWebApp.Data;
using watchInfoWebApp.Models;
using watchInfoWebApp.Services;
using watchInfoWebApp.Tools;
using watchInfoWebApp.ViewModels;

namespace watchInfoWebApp.Controllers
{
    [Authorize]
    [ApiController]
    [Route("Api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        private readonly ILogger<UserController> _logger;

        private IConfiguration _config;
        private IUserService _userService;

        private ClaimsGetter claimsGetter = new ClaimsGetter();

        public UserController(ILogger<UserController> logger, ApplicationDbContext context, IConfiguration config, IUserService userService)
        {
            _logger = logger;
            _context = context;
            if (_context.Users.Count() == 0)
            {
                _context.Users.Add(new User { Username = "admin", Password =  ComputeSha256Hash("admin") });
                _context.SaveChanges();
            }
            _config = config;
            _userService = userService;
        }

        public static string ComputeSha256Hash(string rawData)
        {
            if (string.IsNullOrWhiteSpace(rawData)) throw new ArgumentNullException("The row data cannot be empty.");

            using (SHA256 sha256Hash = SHA256.Create())
            { 
                byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(rawData));

                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }

        [AllowAnonymous]
        [HttpPost("register")]
        public async Task<ActionResult<User>> CreateUser(User user)
        {
            user.Password = ComputeSha256Hash(user.Password);
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            user.Password = null;

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


        [HttpPost("getNameFromUserAndPass")]
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
                Name = foundUser.Name,
                Location = foundUser.Location
            };

            return Ok(loginViewModel);
        }

        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> Authenticate([FromBody]User userParam)
        {
            var user = await _userService.Authenticate(userParam.Username, ComputeSha256Hash(userParam.Password));

            if (user == null)
                return BadRequest(new { message = "Username or password is incorrect" });

            return Ok(user);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var users = await _userService.GetAll();
            return Ok(users);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("changeProject/{newProjectId}")]
        public async Task<IActionResult> ChangeMyProject(int newProjectId)
        {
            var oldProjectId = claimsGetter.ProjectId(User?.Claims);
            var userId = claimsGetter.UserId(User?.Claims);
            var user = await _context.Users.SingleAsync(x => x.Id == userId);
            user.ProjectId = newProjectId;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("changeProjectByUser/{username}/{newProjectId}")]
        public async Task<IActionResult> ChangeMyProjectByUser(string username, int newProjectId)
        {
            var user = await _context.Users.SingleAsync(x => x.Username == username);
            user.ProjectId = newProjectId;
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
