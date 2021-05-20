using System;
using System.Threading.Tasks;
using XFCrossApp.Models;

namespace XFCrossApp.Services
{
    public interface IRestService
    {
        Task<string> GetServerTimeAsync();
        Task<string> LoginAsync(Login login);
    }
}
