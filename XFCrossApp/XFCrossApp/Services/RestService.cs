using System;
using System.Diagnostics;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using XFCrossApp.Helpers;
using XFCrossApp.Models;

namespace XFCrossApp.Services
{
    public class RestService : IRestService
    {
        HttpClient httpClient;

        public RestService()
        {
            httpClient = new HttpClient();
        }

        public async Task<string> GetServerTimeAsync()
        {
            Uri uri = new Uri(string.Format(Constants.ApiURL + "/Api/General/hour",
                string.Empty));

            string result = "No response";
            HttpResponseMessage response;

            try
            {
                response = await httpClient.GetAsync(uri);
            }
            catch(Exception ex)
            {
                Debug.WriteLine(ex);
                response = new HttpResponseMessage {
                    StatusCode = System.Net.HttpStatusCode.InternalServerError
                };
            }
            if (response.IsSuccessStatusCode)
            {
                string content = await response.Content.ReadAsStringAsync();
                result = JsonSerializer.Deserialize<string>(content);
            }
            return result;
        }

        public async Task<string> LoginAsync(Login login)
        {
            Uri uri = new Uri(string.Format(Constants.ApiURL + "/Api/User/login",
                string.Empty));

            HttpContent result = null;
            HttpResponseMessage response;

            string json = JsonSerializer.Serialize<Login>(login);
            StringContent content = new StringContent(json, Encoding.UTF8, "application/json");

            try
            {
                response = await httpClient.PostAsync(uri, content);
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex);
                response = new HttpResponseMessage
                {
                    StatusCode = System.Net.HttpStatusCode.InternalServerError
                };
            }
            if (response.IsSuccessStatusCode)
            {
                result = response.Content;
            }
            return await result?.ReadAsStringAsync();
        }
    }
}
