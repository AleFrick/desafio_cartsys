using System;

namespace ERPFinanceiro.Api.Models
{
    public class FinanceiroDto
    {
        public int Id { get; set; }
        public int VendaId { get; set; }
        public decimal Valor { get; set; }
        public string Status { get; set; }
        public DateTime? DataVencimento { get; set; }
        public DateTime? DataQuitacao { get; set; }
        public DateTime? DataCancelamento { get; set; }
        public string MotivoCancelamento { get; set; }
    }

    public class CriarFinanceiroDto
    {
        public int VendaId { get; set; }
        public decimal Valor { get; set; }
        public DateTime? DataVencimento { get; set; }
    }

    public class MotivoCancelamentoDto
    {
        public string Motivo { get; set; }
    }
}
