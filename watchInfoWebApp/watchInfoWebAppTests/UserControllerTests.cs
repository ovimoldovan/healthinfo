using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Moq;
using watchInfoWebApp.Controllers;
using watchInfoWebApp.Models;
using watchInfoWebApp.Services;
using watchInfoWebApp.ViewModels;
using Xunit;

namespace watchInfoWebAppTests
{
    public class UserControllerTests : BaseTests
    {

        protected UserController userController;
        protected Mock<IUserService> userServiceMock;
        protected LoginViewModel loginViewModel = new LoginViewModel
        {
            Token = "token",
            Username = "user",
            Name = "userName",
            Role = "admin",
            Location = "City",
        };

        public UserControllerTests()
        {
            userServiceMock = new Mock<IUserService>();
            userServiceMock.Setup(us => us.Authenticate("user", "pass")).Returns(Task.FromResult(loginViewModel));
            userController = new UserController(dbContext, userServiceMock.Object);
        }

        [Fact]
        public void AddUser_Creates_User()
        {
            //Arrange
            User user = new User
            {
                Username = "username",
                Password = "test",
                Name = "Name"
            };

            //Act

            var result = userController.CreateUser(user);

            //Assert
            Assert.True(result.Result != null);
        }

        [Fact]
        public void AddUser_WithName_ReturnsName()
        {
            //Arrange
            User user = new User
            {
                Username = "username",
                Password = "test",
                Name = "Name"
            };

            //Act

            var result = userController.CreateUser(user);

            //Assert
            var addedUser = dbContext.Users.First(x => x.Username == user.Username);
            Assert.True(addedUser.Name == "Name");
        }

        [Fact]
        public void AddUser_Password_IsEncrypted()
        {
            //Arrange
            User user = new User
            {
                Username = "username",
                Password = "test",
                Name = "Name"
            };

            //Act

            var result = userController.CreateUser(user);

            //Assert
            var addedUser = dbContext.Users.First(x => x.Username == user.Username);
            Assert.True(addedUser.Password == ComputeSha256HashTest("test"));
        }


        [Fact]
        public void Controller_HashMethod_SameAsTestHashMethod()
        {
            //Arrange
            User user = new User
            {
                Username = "username",
                Password = "test",
                Name = "Name"
            };

            //Act
            var result = UserController.ComputeSha256Hash(user.Password);

            //Assert
            Assert.True(result == ComputeSha256HashTest(user.Password));
        }

        [Fact]
        public void UserService_AuthWithWrongData_ReturnsNull()
        {
            //Arrange
            User user = new User
            {
                Username = "Non-Existant-User",
                Password = "test",
            };

            //Act
            var result = userServiceMock.Object.Authenticate(user.Username, user.Password).Result;

            //Assert
            Assert.True(result == null);
        }
        
        [Fact]
        public void UserService_AuthWithGoodData_Works()
        {
            //Arrange
            User user = new User
            {
                Username = "user",
                Password = "pass",
            };

            //Act
            var result = userServiceMock.Object.Authenticate(user.Username, user.Password).Result;

            //Assert
            Assert.True(result != null);
        }   
        
        [Fact]
        public void UserService_AuthWithGoodData_ReturnsToken()
        {
            //Arrange
            User user = new User
            {
                Username = "user",
                Password = "pass",
            };

            //Act
            var result = userServiceMock.Object.Authenticate(user.Username, user.Password).Result;

            //Assert
            Assert.True(result.Token == loginViewModel.Token);
        }

        public static string ComputeSha256HashTest(string rawData)
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
    }
}
