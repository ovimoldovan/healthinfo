using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using XFCrossApp.Models;

namespace XFCrossApp.Services
{
    public interface IPluralsightDataStore
    {
        Task<String> AddNoteAsync(Note courseNote);
        Task<bool> UpdateNoteAsync(Note courseNote);
        Task<Note> GetNoteAsync(String id);
        Task<IList<Note>> GetNotesAsync();
        Task<IList<String>> GetCoursesAsync(); 
    }
}
