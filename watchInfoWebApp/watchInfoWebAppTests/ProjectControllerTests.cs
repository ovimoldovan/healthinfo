using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Moq;
using watchInfoWebApp.Controllers;
using watchInfoWebApp.Models;
using watchInfoWebApp.Services;
using Xunit;

namespace watchInfoWebAppTests
{
    public class ProjectControllerTests : BaseTests
    {

        protected ProjectController projectController;

        public ProjectControllerTests()
        {
            projectController = new ProjectController(dbContext);
        }

        [Fact]
        public void AddProject_Returns_Ok()
        {
            //Arrange
            Project project = new Project
            {
                Name = "nume"
            };

            //Act

            var result = projectController.CreateProject(project);

            //Assert
            Assert.IsType<ActionResult<Project>>(result.Result);
        }

        [Fact]
        public void AddProject_Returns_Name()
        {
            //Arrange
            Project project = new Project
            {
                Name = "nume"
            };

            //Act

            var result = projectController.CreateProject(project);

            //Assert
            var addedProject = dbContext.Projects.First(x => x.Name == project.Name);
            Assert.True(addedProject.Name == project.Name);
        }
    }
}
