using System;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Threading.Tasks;

using Xamarin.Forms;

using XFCrossApp.Models;
using XFCrossApp.Views;

namespace XFCrossApp.ViewModels
{
    public class ItemsViewModel : BaseViewModel
    {
        public ObservableCollection<Note> Notes { get; set; }
        public Command LoadItemsCommand { get; set; }

        public ItemsViewModel()
        {
            Title = "Browse";
            Notes = new ObservableCollection<Note>();
            LoadItemsCommand = new Command(async () => await ExecuteLoadItemsCommand());

            MessagingCenter.Subscribe<ItemDetailPage, Note>(this, "SaveNote",
                async (sender, note) => {
                    Notes.Add(note);
                    await PluralsightDataStore.AddNoteAsync(note);
            });

            MessagingCenter.Subscribe<ItemDetailPage, Note>(this, "EditNote",
                async (sender, note) =>
                {
                    await PluralsightDataStore.UpdateNoteAsync(note);
                    await ExecuteLoadItemsCommand();
                });
        }

        async Task ExecuteLoadItemsCommand()
        {
            IsBusy = true;

            try
            {
                Notes.Clear();
                var notes = await PluralsightDataStore.GetNotesAsync();
                foreach (var note in notes)
                {
                    Notes.Add(note);
                }
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
    }
}