using System.Linq;
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
                _context.Users.Add(new User { Username = "admin", Password = "admin" });
                _context.SaveChanges();
            }
            _config = config;
            _userService = userService;
        }


        [HttpPost("register")]
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
                Name = foundUser.Name
            };

            return Ok(loginViewModel);
        }

        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> Authenticate([FromBody]User userParam)
        {
            var user = await _userService.Authenticate(userParam.Username, userParam.Password);

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
    }
}
