using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

using XFCrossApp.Models;
using XFCrossApp.Views;
using XFCrossApp.ViewModels;

namespace XFCrossApp.Views
{
    public partial class ItemsPage : ContentPage
    {
        ItemsViewModel viewModel;

        public ItemsPage()
        {
            InitializeComponent();

            BindingContext = viewModel = new ItemsViewModel();
        }

        async void OnItemSelected(object sender, EventArgs args)
        {
            var layout = (BindableObject)sender;
            var note = (Note)layout.BindingContext;
            if (note == null) return;
            await Navigation.PushModalAsync(new NavigationPage(new ItemDetailPage(new ItemDetailViewModel(note))));
        }

        async void AddItem_Clicked(object sender, EventArgs e)
        {
            await Navigation.PushModalAsync(new NavigationPage(new ItemDetailPage()));
        }

        protected override void OnAppearing()
        {
            base.OnAppearing();

            if (viewModel.Notes.Count == 0)
                viewModel.IsBusy = true;
        }
    }
}