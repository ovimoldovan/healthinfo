using System;
using System.ComponentModel.DataAnnotations;

namespace watchInfoWebApp.ViewModels
{
    public class LoginViewModel
    {
        [Required]
        public string Token { get; set; }
        [Required]
        public string Username { get; set; }

        public string Name { get; set; }

    }
}
