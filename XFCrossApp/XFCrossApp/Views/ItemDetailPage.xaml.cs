using System;
using System.Collections.Generic;
using System.ComponentModel;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

using XFCrossApp.Models;
using XFCrossApp.Services;
using XFCrossApp.ViewModels;

namespace XFCrossApp.Views
{
    public partial class ItemDetailPage : ContentPage
    {
        ItemDetailViewModel viewModel;

        public ItemDetailPage(ItemDetailViewModel viewModel)
        {
            InitializeComponent();

            this.viewModel = viewModel;
            BindingContext = this.viewModel;
        }

        public ItemDetailPage()
        {
            InitializeComponent();

            viewModel = new ItemDetailViewModel();
            BindingContext = viewModel;
        }

        void Save_Clicked(object sender, EventArgs e)
        {
            var message = viewModel.IsNew ? "SaveNote" : "EditNote";

            MessagingCenter.Send(this, message, viewModel.Note);

            Navigation.PopModalAsync();
        }

        void Cancel_Clicked(object sender, EventArgs e)
        {
            Navigation.PopModalAsync();
        }
    }
}