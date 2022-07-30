using System;
using System.ComponentModel;

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
        public double Temperature { get; set; }
        public double RelativeAltitude { get; set; }
        public double AbsoluteAltitude { get; set; }
        public double Pressure { get; set; }
        public DateTime SentDate { get; set; }
        public string Device { get; set; }
        [DefaultValue(0)]
        public int ProjectId { get; set; }
    }
}
