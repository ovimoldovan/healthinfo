using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using Moq;
using watchInfoWebApp.Controllers;
using watchInfoWebApp.Models;
using watchInfoWebApp.Services;
using Xunit;

namespace watchInfoWebAppTests
{
    public class UserControllerTests : BaseTests
    {

        protected UserController userController;
        protected Mock<IUserService> userService;

        public UserControllerTests()
        {
            userService = new Mock<IUserService>();
            userController = new UserController(dbContext, userService.Object);
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
