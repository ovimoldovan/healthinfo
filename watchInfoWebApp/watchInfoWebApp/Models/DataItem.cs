using System;
namespace watchInfoWebApp.Models
{
    public class DataItem
    {
        public long Id { get; set; }
        public int UserId { get; set; }
        public int HeartBpm { get; set; }
        public string GpsCoordinates { get; set; }
        public int Steps { get; set; }
        public double Distance { get; set; }
        public DateTime SentDate { get; set; }
    }
}
