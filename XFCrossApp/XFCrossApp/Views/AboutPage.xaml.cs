using System;
using System.ComponentModel;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using XFCrossApp.ViewModels;

namespace XFCrossApp.Views
{
    public partial class AboutPage : ContentPage
    {
        AboutViewModel viewModel;

        public AboutPage(AboutViewModel viewModel)
        {
            InitializeComponent();

            this.viewModel = viewModel;
            BindingContext = this.viewModel;
        }

        public AboutPage()
        {
            InitializeComponent();

            viewModel = new AboutViewModel();
            BindingContext = viewModel;
        }

        void GetDate_Clicked(object sender, EventArgs e)
        {
            var message = "GetDate";

            MessagingCenter.Send(this, message, viewModel.TimeLabel);
        }

        void Login_Clicked(Object sender, EventArgs e)
        {
            var message = "SendLogin";

            MessagingCenter.Send(this, message, viewModel.DisplayName);
        }
    }
}