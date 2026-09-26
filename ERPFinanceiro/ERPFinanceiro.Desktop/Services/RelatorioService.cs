using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Web.Script.Serialization;
using ERPFinanceiro.Desktop.Models;

namespace ERPFinanceiro.Desktop.Services
{
    public class RelatorioService
    {
        private readonly string _baseUrl;

        public RelatorioService(string baseUrl)
        {
            _baseUrl = baseUrl.TrimEnd('/');
        }

        public List<RelatorioFinanceiroDto> Buscar(
            DateTime? dataInicial,
            DateTime? dataFinal,
            string status)
        {
            var url = _baseUrl + "/api/financeiro/relatorio";
            var parametros = new List<string>();

            if (dataInicial.HasValue)
            {
                parametros.Add(
                    "dataInicial=" +
                    Uri.EscapeDataString(
                        dataInicial.Value.ToString("yyyy-MM-dd")));
            }

            if (dataFinal.HasValue)
            {
                parametros.Add(
                    "dataFinal=" +
                    Uri.EscapeDataString(
                        dataFinal.Value.ToString("yyyy-MM-dd")));
            }

            if (!string.IsNullOrWhiteSpace(status))
            {
                parametros.Add(
                    "status=" +
                    Uri.EscapeDataString(status));
            }

            if (parametros.Count > 0)
                url += "?" + string.Join("&", parametros);

            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Add(
                    "Accept",
                    "application/json");

                var response = client
                    .GetAsync(url)
                    .GetAwaiter()
                    .GetResult();

                response.EnsureSuccessStatusCode();

                var json = response.Content
                    .ReadAsStringAsync()
                    .GetAwaiter()
                    .GetResult();

                var serializer = new JavaScriptSerializer();

                return serializer.Deserialize<
                    List<RelatorioFinanceiroDto>>(json);
            }
        }
    }
}
