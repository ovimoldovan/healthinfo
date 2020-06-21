using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;
using watchInfoWebApp.Data;
using watchInfoWebApp.Models;
using watchInfoWebApp.ViewModels;

namespace watchInfoWebApp.Services
{
    public interface IUserService
    {
        Task<LoginViewModel> Authenticate(string username, string password);
        Task<IEnumerable<User>> GetAll();
    }

    public class UserService : IUserService
    {
        private readonly ApplicationDbContext _context;
        private List<User> _users;
        private IConfiguration _config;

        public UserService(ApplicationDbContext context, IConfiguration config)
        {
            _context = context;
            _users = _context.Users.ToList();
            _config = config;
        }

        public async Task<LoginViewModel> Authenticate(string username, string password)
        {
            try
            {
                var user = await Task.Run(() => _users.SingleOrDefault(x => x.Username == username && x.Password == password));

                if (user == null)
                    return null;

                var userData = new User { Id = user.Id, Username = user.Username, Name = user.Name, ProjectId = user.ProjectId, Role = user.Role };

                var token = GenerateJSONWebToken(userData);

                return new LoginViewModel
                {
                    Token = token,
                    Username = user.Username,
                    Name = user.Name,
                    Role = user.Role,
                    Location = user.Location
                };
            }
            catch
            {
                return null;
            }
        }

        private string GenerateJSONWebToken(User userInfo)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new Claim[] {
                    new Claim(ClaimTypes.NameIdentifier, userInfo.Id.ToString()),
                    new Claim(ClaimTypes.Name, userInfo.Username),
                    new Claim(ClaimTypes.Role, userInfo.Role ?? "User"),
                    new Claim(ClaimTypes.GroupSid, userInfo.ProjectId.ToString())
                }),
                Expires = DateTime.Now.AddDays(1),
                SigningCredentials = credentials
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        public async Task<IEnumerable<User>> GetAll()
        {
            return await Task.Run(() => _users.Select(x => {
                x.Password = null;
                return x;
            }));
        }
    }
}
