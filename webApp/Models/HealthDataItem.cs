using System;
using Microsoft.EntityFrameworkCore;
namespace webApp.Models
{
    public class HealthDataItem
    {
        public long Id { get; set; }
        public ApplicationUser User { get; set; }
        public int HeartBpm { get; set; }
        public string GpsCoordinates { get; set; }
        public int Steps { get; set; }
        public double Distance { get; set; }
    }
}
