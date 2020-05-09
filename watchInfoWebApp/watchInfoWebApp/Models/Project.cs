using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace watchInfoWebApp.Models
{
    public class Project
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }

        public int CreatedByUserId { get; set; }

        public DateTime StartTime { get; set; }
    }
}
