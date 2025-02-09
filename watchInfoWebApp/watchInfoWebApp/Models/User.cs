﻿using System;
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
        public string Location { get; set; }

        public List<DataItem> DataItems { get; set; }

        public int ProjectId { get; set; }

        public string Role { get; set; }
    }
}
