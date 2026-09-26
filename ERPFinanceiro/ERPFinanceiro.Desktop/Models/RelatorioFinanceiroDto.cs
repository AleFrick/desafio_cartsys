using System;

namespace ERPFinanceiro.Desktop.Models
{
    public class RelatorioFinanceiroDto
    {
        public int VendaId { get; set; }
        public DateTime DataVenda { get; set; }
        public string Cliente { get; set; }
        public decimal Valor { get; set; }
        public string Status { get; set; }
        public DateTime? DataVencimento { get; set; }
        public DateTime? DataQuitacao { get; set; }
        public DateTime? DataCancelamento { get; set; }
        public string MotivoCancelamento { get; set; }
    }
}
