using System;
using System.Diagnostics;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using System.Windows.Input;
using Newtonsoft.Json;
using Xamarin.Essentials;
using Xamarin.Forms;
using XFCrossApp.Models;
using XFCrossApp.Services;
using XFCrossApp.Views;

namespace XFCrossApp.ViewModels
{
    public class AboutViewModel : BaseViewModel
    {
        public ICommand GetServerTimeCommand { get; }
        public IRestService restService;
        private string Time = "Not yet";

        public Login Login = new Login();
        public String TimeLabel
        {
            get
            {
                return Time;
            }
            set
            {
                Time = value;
                OnPropertyChanged();
            }
        }

        public string Username
        {
            get
            {
                return Login.Username;
            }
            set
            {
                Login.Username = value;
                OnPropertyChanged();
            }
        }

        public string Password
        {
            get
            {
                return Login.Password;
            }
            set
            {
                Login.Password = value;
                OnPropertyChanged();
            }
        }

        public string DisplayName
        {
            get
            {
                if(Login!=null)
                    return Login.Name;
                return "Not logged in";
            }
            set
            {
                Login.Name = value;
                OnPropertyChanged();
            }
        }
        

        public AboutViewModel()
        {
            restService = new RestService();
            Title = "User info";
            GetServerTimeCommand = new Command(async () => await ExecuteLoadTime());

            MessagingCenter.Subscribe<AboutPage, string>(this, "GetDate",
                async (sender, item) =>
                {
                    await ExecuteLoadTime();
                });
            MessagingCenter.Subscribe<AboutPage, string>(this, "SendLogin",
                async (sender, item) =>
                {
                    await ExecuteLogin();
                });
        }

        async Task ExecuteLoadTime()
        {
            IsBusy = true;

            try
            {
                var result = await restService.GetServerTimeAsync();
                TimeLabel = result;
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex);
            }
            finally
            {
                IsBusy = false;
            }
        }

        async Task ExecuteLogin()
        {
            IsBusy = true;
            string result = "";

            try
            {
                result = await restService.LoginAsync(new Login
                {
                    Username = Username,
                    Password = Password,
                });
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex);
            }
            finally
            {
                Login = JsonConvert.DeserializeObject<Login>(result) ?? new Login();
                if (Login != null)
                {
                    DisplayName = Login?.Name ?? "something failed";
                }
                IsBusy = false;
            }
        }

    }
}