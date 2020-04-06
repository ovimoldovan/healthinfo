using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Identity;

namespace watchInfoWebApp.Models
{
    public class User
    {
        public long Id { get; set; }

        public string Username { get; set; }
        public string Password { get; set; }
        public string Name { get; set; }

        public List<DataItem> DataItems { get; set; }
    }
}
