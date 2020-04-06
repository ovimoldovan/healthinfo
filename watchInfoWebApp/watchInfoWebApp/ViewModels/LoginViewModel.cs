using System;
using System.ComponentModel.DataAnnotations;

namespace watchInfoWebApp.ViewModels
{
    public class LoginViewModel
    {

        [Required]
        [Display(Name = "Username")]
        public string Username { get; set; }

        public string Name { get; set; }

    }
}
