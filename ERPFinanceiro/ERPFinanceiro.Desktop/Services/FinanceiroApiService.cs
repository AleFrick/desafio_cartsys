    using ERPFinanceiro.Desktop.Models;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web.Script.Serialization;

namespace ERPFinanceiro.Desktop.Services
{
    public class FinanceiroApiService
    {
        private readonly HttpClient _httpClient;
        private readonly JavaScriptSerializer _json = new JavaScriptSerializer();

        public FinanceiroApiService(string baseUrl)
        {
            _httpClient = new HttpClient
            {
                BaseAddress = new Uri(baseUrl.TrimEnd('/') + "/"),
                Timeout = TimeSpan.FromSeconds(15)
            };

            _httpClient.DefaultRequestHeaders.Accept.Clear();
            _httpClient.DefaultRequestHeaders.Accept.Add(
                new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
        }

        public List<FinanceiroDto> Listar()
        {
            var response = _httpClient.GetAsync("api/financeiro").GetAwaiter().GetResult();
            var body = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();

            if (!response.IsSuccessStatusCode)
                throw new Exception(ExtrairMensagem(response.StatusCode, body));

            return _json.Deserialize<List<FinanceiroDto>>(body)
                   ?? new List<FinanceiroDto>();
        }

        public ApiResult Quitar(int vendaId)
        {
            return Post("api/financeiro/venda/" + vendaId + "/quitar", null);
        }

        public ApiResult Cancelar(int vendaId, string motivo)
        {
            var payload = _json.Serialize(new { motivo = motivo });
            return Post("api/financeiro/venda/" + vendaId + "/cancelar", payload);
        }

        private ApiResult Post(string endpoint, string json)
        {
            HttpContent content = json == null
                ? null
                : new StringContent(json, Encoding.UTF8, "application/json");

            var response = _httpClient.PostAsync(endpoint, content).GetAwaiter().GetResult();
            var body = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();

            return new ApiResult
            {
                Success = response.IsSuccessStatusCode,
                Message = ExtrairMensagem(response.StatusCode, body),
                RawResponse = body
            };
        }

        private string ExtrairMensagem(HttpStatusCode statusCode, string body)
        {
            try
            {
                var obj = _json.DeserializeObject(body) as Dictionary<string, object>;
                if (obj != null)
                {
                    object value;
                    if (obj.TryGetValue("mensagem", out value) && value != null)
                        return value.ToString();
                    if (obj.TryGetValue("message", out value) && value != null)
                        return value.ToString();
                    if (obj.TryGetValue("erro", out value) && value != null)
                        return value.ToString();
                }
            }
            catch { }

            return $"Erro HTTP {(int)statusCode} - {statusCode}.";
        }
    }
}
