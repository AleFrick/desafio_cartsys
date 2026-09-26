using System;

namespace ERPFinanceiro.Api.Models
{
    public class RelatorioFinanceiroDto
    {
        public int Id { get; set; }

        public int VendaId { get; set; }

        public DateTime DataVenda { get; set; }

        public int ClienteId { get; set; }

        public string ClienteNome { get; set; }

        public decimal Valor { get; set; }

        public string StatusFinanceiro { get; set; }

        public string StatusVenda { get; set; }

        public DateTime? DataVencimento { get; set; }

        public DateTime? DataQuitacao { get; set; }

        public DateTime? DataCancelamento { get; set; }

        public string MotivoCancelamento { get; set; }
    }
}       