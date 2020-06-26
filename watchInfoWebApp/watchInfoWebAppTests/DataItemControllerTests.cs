using System.Linq;
using watchInfoWebApp.Controllers;
using watchInfoWebApp.Models;
using Xunit;

namespace watchInfoWebAppTests
{
    public class DataItemControllerTests : BaseTests
    {

        protected DataItemController dataItemController;

        public DataItemControllerTests()
        { 
            dataItemController = new DataItemController(dbContext);
        }

        [Fact]
        public void AddDataItem_Creates_DataItem()
        {
            //Arrange
            DataItem dataItem = new DataItem
            {
                HeartBpm = 80
            };

            //Act

            var result = dataItemController.PostDataItem(dataItem);

            //Assert
            Assert.True(result.Result != null);
        }

        [Fact]
        public void AddDataItem_Returns_DataItem()
        {
            //Arrange
            DataItem dataItem = new DataItem
            {
                Id = 1,
                HeartBpm = 80
            };

            //Act

            var result = dataItemController.PostDataItem(dataItem);

            //Assert
            var addedProject = dbContext.DataItems.First(x => x.Id == dataItem.Id);
            Assert.True(addedProject.HeartBpm == dataItem.HeartBpm);
        }
    }
}
