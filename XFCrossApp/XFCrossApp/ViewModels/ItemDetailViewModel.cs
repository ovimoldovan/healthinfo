using System;
using System.Collections.Generic;
using XFCrossApp.Models;

namespace XFCrossApp.ViewModels
{
    public class ItemDetailViewModel : BaseViewModel
    {
        public Note Note { get; set; }
        public IList<String> CourseList { get; set; }
        public bool IsNew { get; set; }

        public String NoteHeading
        {
            get { return Note.Heading; }
            set
            {
                Note.Heading = value;
                OnPropertyChanged();
            }
        }

        public ItemDetailViewModel(Note note = null)
        {
            IsNew = note == null;

            Title = IsNew ? "Add Note" : "Edit Note";

            InitializaCourseList();
            Note = note ?? new Note();
        }

        async void InitializaCourseList()
        {
            CourseList = await PluralsightDataStore.GetCoursesAsync();
        }
    }
}
