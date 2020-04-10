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

                // return null if user not found
                if (user == null)
                    return null;

                var userData = new User { Id = user.Id, Username = user.Username, Name = user.Name };

                var token = GenerateJSONWebToken(userData);

                return new LoginViewModel
                {
                    Token = token,
                    Username = user.Username,
                    Name = user.Name
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
                    new Claim(ClaimTypes.Name, userInfo.Username)
                }),
                Expires = DateTime.Now.AddDays(1),
                SigningCredentials = credentials
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        /*
         *             var handler = new JwtSecurityTokenHandler();

            ClaimsIdentity identity = new ClaimsIdentity
            (
                new GenericIdentity(userInfo.Username, "Token"),
                new[]
                {
                    new Claim("ID", userInfo.Id.ToString())
                }
            );

            var keyByteArray = Encoding.ASCII.GetBytes("securityStringHatzJohnuleJohnutzule");

            var signingKey = new Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(keyByteArray);
            var securityToken = handler.CreateToken(new SecurityTokenDescriptor
            {
                Issuer = "Issuer",
                Audience = "Audience",
                SigningCredentials = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256),
                Subject = identity,
                Expires = DateTime.Now.Add(TimeSpan.FromDays(1)),
                NotBefore = DateTime.Now
            });
            return handler.WriteToken(securityToken);
            */

        public async Task<IEnumerable<User>> GetAll()
        {
            // return users without passwords
            return await Task.Run(() => _users.Select(x => {
                x.Password = null;
                return x;
            }));
        }
    }
}
