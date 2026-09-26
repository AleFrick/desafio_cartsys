    using System.IO;        
    using ERPFinanceiro.Desktop.Models;
    using ERPFinanceiro.Desktop.Services;
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Drawing;
    using System.Linq;
    using System.Windows.Forms;

    // FastReport
    using FastReport;
    using FastReport.Export.PdfSimple;
    using System.Diagnostics;

    namespace ERPFinanceiro.Desktop.Forms
    {
        public class FrmFinanceiro : Form
        {
            private readonly FinanceiroApiService _api;
            private readonly RelatorioService _relatorioService;

            private DataGridView _grid;
            private TextBox _txtVenda;
            private ComboBox _cmbStatus;
            private DateTimePicker _dtInicio;
            private DateTimePicker _dtFim;

            private Button _btnAtualizar;
            private Button _btnQuitar;
            private Button _btnCancelar;
            private Button _btnLimpar;
            private Button _btnRelatorio;

            private Label _lblResumo;
            private Label _lblApi;

            private List<FinanceiroDto> _dados =
                new List<FinanceiroDto>();

            public FrmFinanceiro()
            {
                _api = new FinanceiroApiService(
                    "http://localhost:5000/");

                _relatorioService = new RelatorioService(
                    "http://localhost:5000/");

                InicializarTela();

                CarregarFinanceiro();
            }

            private void InicializarTela()
            {
                Text = "ERP Financeiro";

                StartPosition =
                    FormStartPosition.CenterScreen;

                Width = 1100;
                Height = 650;

                MinimumSize =
                    new Size(900, 550);

                Font = new Font(
                    "Segoe UI",
                    9F);

                BackColor = Color.White;

                // =====================================================
                // PAINEL SUPERIOR
                // =====================================================

                var painelTopo = new Panel
                {
                    Dock = DockStyle.Top,
                    Height = 125,
                    BackColor = Color.White
                };

                var titulo = new Label
                {
                    Text = "Financeiro",
                    Font = new Font(
                        "Segoe UI Semibold",
                        18F),
                    AutoSize = true,
                    Location = new Point(20, 14)
                };

                painelTopo.Controls.Add(titulo);

                // Venda

                var lblVenda = new Label
                {
                    Text = "Venda:",
                    AutoSize = true,
                    Location = new Point(22, 58)
                };

                _txtVenda = new TextBox
                {
                    Location = new Point(70, 55),
                    Width = 100
                };

                _txtVenda.KeyPress += TxtVenda_KeyPress;

                // Status

                var lblStatus = new Label
                {
                    Text = "Status:",
                    AutoSize = true,
                    Location = new Point(190, 58)
                };

                _cmbStatus = new ComboBox
                {
                    Location = new Point(240, 55),
                    Width = 120,
                    DropDownStyle =
                        ComboBoxStyle.DropDownList
                };

                _cmbStatus.Items.AddRange(
                    new object[]
                    {
                        "Todos",
                        "PENDENTE",
                        "QUITADA",
                        "CANCELADA"
                    });

                _cmbStatus.SelectedIndex = 0;

                // Data inicial

                var lblInicio = new Label
                {
                    Text = "Vencimento de:",
                    AutoSize = true,
                    Location = new Point(380, 58)
                };

                _dtInicio = new DateTimePicker
                {
                    Location = new Point(480, 55),
                    Width = 120,
                    Format = DateTimePickerFormat.Short,
                    ShowCheckBox = true
                };

                // Data final

                var lblFim = new Label
                {
                    Text = "até:",
                    AutoSize = true,
                    Location = new Point(615, 58)
                };

                _dtFim = new DateTimePicker
                {
                    Location = new Point(645, 55),
                    Width = 120,
                    Format = DateTimePickerFormat.Short,
                    ShowCheckBox = true
                };

                // Atualizar

                _btnAtualizar =
                    CriarBotao(
                        "Atualizar",
                        790,
                        52,
                        100);

                _btnAtualizar.Click +=
                    (s, e) => CarregarFinanceiro();

                // Limpar

                _btnLimpar =
                    CriarBotao(
                        "Limpar",
                        895,
                        52,
                        80);

                _btnLimpar.Click +=
                    BtnLimpar_Click;

                painelTopo.Controls.AddRange(
                    new Control[]
                    {
                        lblVenda,
                        _txtVenda,
                        lblStatus,
                        _cmbStatus,
                        lblInicio,
                        _dtInicio,
                        lblFim,
                        _dtFim,
                        _btnAtualizar,
                        _btnLimpar
                    });

                // =====================================================
                // GRID
                // =====================================================

                _grid = new DataGridView
                {
                    Dock = DockStyle.Fill,

                    BackgroundColor = Color.White,

                    BorderStyle =
                        BorderStyle.FixedSingle,

                    AllowUserToAddRows = false,
                    AllowUserToDeleteRows = false,
                    AllowUserToResizeRows = false,

                    ReadOnly = true,

                    MultiSelect = false,

                    SelectionMode =
                        DataGridViewSelectionMode.FullRowSelect,

                    AutoGenerateColumns = false,

                    RowHeadersVisible = false,

                    AutoSizeRowsMode =
                        DataGridViewAutoSizeRowsMode.None
                };

                CriarColuna(
                    "ID",
                    "Id",
                    60);

                CriarColuna(
                    "Venda",
                    "VendaId",
                    70);

                CriarColuna(
                    "Valor",
                    "Valor",
                    110,
                    "C");

                CriarColuna(
                    "Vencimento",
                    "DataVencimento",
                    110,
                    "dd/MM/yyyy");

                CriarColuna(
                    "Status",
                    "Status",
                    110);

                CriarColuna(
                    "Quitação",
                    "DataQuitacao",
                    120,
                    "dd/MM/yyyy HH:mm");

                CriarColuna(
                    "Cancelamento",
                    "DataCancelamento",
                    130,
                    "dd/MM/yyyy HH:mm");

                CriarColuna(
                    "Motivo",
                    "MotivoCancelamento",
                    300);

                _grid.CellDoubleClick +=
                    Grid_CellDoubleClick;

                _grid.CellFormatting +=
                    Grid_CellFormatting;

                // =====================================================
                // RODAPÉ
                // =====================================================

                var painelRodape = new Panel
                {
                    Dock = DockStyle.Bottom,
                    Height = 58,
                    BackColor = Color.WhiteSmoke
                };

                // Quitar

                _btnQuitar =
                    CriarBotao(
                        "Quitar",
                        15,
                        12,
                        100);

                _btnQuitar.Click +=
                    BtnQuitar_Click;

                // Cancelar

                _btnCancelar =
                    CriarBotao(
                        "Cancelar",
                        125,
                        12,
                        100);

                _btnCancelar.Click +=
                    BtnCancelar_Click;

                // Relatório

                _btnRelatorio =
                    CriarBotao(
                        "Relatório",
                        235,
                        12,
                        100);

                _btnRelatorio.Click +=
                    BtnRelatorio_Click;

                // Resumo

                _lblResumo = new Label
                {
                    AutoSize = true,

                    Location =
                        new Point(350, 20),

                    Font =
                        new Font(
                            "Segoe UI Semibold",
                            9F)
                };

                // API

                _lblApi = new Label
                {
                    AutoSize = true,

                    Anchor =
                        AnchorStyles.Top |
                        AnchorStyles.Right,

                    Location =
                        new Point(850, 20),

                    Text =
                        "API: http://localhost:5000",

                    ForeColor =
                        Color.DimGray
                };

                painelRodape.Controls.AddRange(
                    new Control[]
                    {
                        _btnQuitar,
                        _btnCancelar,
                        _btnRelatorio,
                        _lblResumo,
                        _lblApi
                    });

                Controls.Add(_grid);
                Controls.Add(painelRodape);
                Controls.Add(painelTopo);
            }

            private Button CriarBotao(
                string texto,
                int x,
                int y,
                int largura)
            {
                return new Button
                {
                    Text = texto,

                    Location =
                        new Point(x, y),

                    Width = largura,

                    Height = 32,

                    FlatStyle =
                        FlatStyle.System
                };
            }

            private void CriarColuna(
                string titulo,
                string propriedade,
                int largura,
                string formato = null)
            {
                var coluna =
                    new DataGridViewTextBoxColumn
                    {
                        HeaderText = titulo,

                        DataPropertyName =
                            propriedade,

                        Width = largura,

                        SortMode =
                            DataGridViewColumnSortMode.Automatic
                    };

                if (!string.IsNullOrEmpty(formato))
                {
                    coluna.DefaultCellStyle.Format =
                        formato;
                }

                _grid.Columns.Add(coluna);
            }

            // =========================================================
            // CARREGAMENTO
            // =========================================================

            private void CarregarFinanceiro()
            {
                Cursor = Cursors.WaitCursor;

                try
                {
                    _dados =
                        _api.Listar();

                    AplicarFiltros();

                    _lblApi.Text =
                        "API: conectada";

                    _lblApi.ForeColor =
                        Color.DarkGreen;
                }
                catch (Exception ex)
                {
                    _lblApi.Text =
                        "API: erro";

                    _lblApi.ForeColor =
                        Color.DarkRed;

                    MessageBox.Show(
                        "Não foi possível consultar o financeiro.\r\n\r\n" +
                        ex.Message +
                        "\r\n\r\n" +
                        "Verifique se a API está executando em " +
                        "http://localhost:5000.",
                        "ERP Financeiro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                }
                finally
                {
                    Cursor = Cursors.Default;
                }
            }

            private void AplicarFiltros()
            {
                IEnumerable<FinanceiroDto> consulta =
                    _dados;

                int venda;

                if (int.TryParse(
                    _txtVenda.Text.Trim(),
                    out venda))
                {
                    consulta =
                        consulta.Where(
                            x => x.VendaId == venda);
                }

                string status =
                    _cmbStatus.SelectedItem?.ToString();

                if (!string.IsNullOrEmpty(status) &&
                    status != "Todos")
                {
                    consulta =
                        consulta.Where(
                            x => string.Equals(
                                x.Status,
                                status,
                                StringComparison.OrdinalIgnoreCase));
                }

                if (_dtInicio.Checked)
                {
                    consulta =
                        consulta.Where(
                            x =>
                                x.DataVencimento.HasValue &&
                                x.DataVencimento.Value.Date >=
                                _dtInicio.Value.Date);
                }

                if (_dtFim.Checked)
                {
                    consulta =
                        consulta.Where(
                            x =>
                                x.DataVencimento.HasValue &&
                                x.DataVencimento.Value.Date <=
                                _dtFim.Value.Date);
                }

                var lista =
                    consulta.ToList();

                _grid.DataSource = null;

                _grid.DataSource =
                    lista;

                decimal total =
                    lista.Sum(x => x.Valor);

                _lblResumo.Text =
                    $"Registros: {lista.Count}    Total: {total:C}";
            }

            // =========================================================
            // RELATÓRIO
            // =========================================================

            private void BtnRelatorio_Click(
                object sender,
                EventArgs e)
            {
                try
                {
                    Cursor = Cursors.WaitCursor;

                    DateTime? dataInicial =
                        _dtInicio.Checked
                            ? _dtInicio.Value.Date
                            : (DateTime?)null;

                    DateTime? dataFinal =
                        _dtFim.Checked
                            ? _dtFim.Value.Date
                            : (DateTime?)null;

                    string status =
                        _cmbStatus.SelectedItem?.ToString();

                    if (status == "Todos")
                        status = null;

                    // Busca os dados do relatório na API
                    var registros =
                        _relatorioService.Buscar(
                            dataInicial,
                            dataFinal,
                            status);

                    if (registros == null ||
                        registros.Count == 0)
                    {
                        MessageBox.Show(
                            "Nenhum registro encontrado para os filtros informados.",
                            "Relatório Financeiro",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Information);

                        return;
                    }

                    // Converte os registros para DataTable
                    DataTable tabela =
                        CriarDataTableRelatorio(registros);

                    using (var report = new Report())
                    {
                        // Localização do arquivo FRX
                        string caminho =
                            Path.Combine(
                                Application.StartupPath,
                                "Relatorios",
                                "RelatorioFinanceiro.frx");

                        if (!File.Exists(caminho))
                        {
                            MessageBox.Show(
                                "O arquivo do relatório não foi encontrado:\r\n\r\n" +
                                caminho +
                                "\r\n\r\n" +
                                "Adicione o arquivo RelatorioFinanceiro.frx " +
                                "à pasta Relatorios do projeto.",
                                "Relatório Financeiro",
                                MessageBoxButtons.OK,
                                MessageBoxIcon.Warning);

                            return;
                        }

                        // =====================================================
                        // CARREGA O TEMPLATE
                        // =====================================================

                        report.Load(caminho);
                        
                        report.RegisterData(
                            tabela,
                            "Financeiro");


                        // =====================================================
                        // LOCALIZA O DATASOURCE
                        // =====================================================

                        var dataSource =
                            report.GetDataSource(
                                "Financeiro");

                        if (dataSource == null)
                        {
                            MessageBox.Show(
                                "A fonte de dados 'Financeiro' não foi encontrada " +
                                "no relatório.",
                                "Relatório Financeiro",
                                MessageBoxButtons.OK,
                                MessageBoxIcon.Error);

                            return;
                        }


                        // Habilita o datasource
                        dataSource.Enabled = true;


                        // =====================================================
                        // VINCULA O DATABAND AO DATASOURCE
                        // =====================================================

                        var dataBand =
                            report.FindObject(
                                "Data1") as DataBand;

                        if (dataBand == null)
                        {
                            MessageBox.Show(
                                "O DataBand 'Data1' não foi encontrado " +
                                "no arquivo do relatório.",
                                "Relatório Financeiro",
                                MessageBoxButtons.OK,
                                MessageBoxIcon.Error);

                            return;
                        }

                        dataBand.DataSource =
                            dataSource;


                        // =====================================================
                        // PREPARA O RELATÓRIO
                        // =====================================================

                        if (!report.Prepare())
                        {
                            MessageBox.Show(
                                "Não foi possível preparar o relatório.",
                                "Relatório Financeiro",
                                MessageBoxButtons.OK,
                                MessageBoxIcon.Error);

                            return;
                        }


                        // =====================================================
                        // CRIA A PASTA DE RELATÓRIOS
                        // =====================================================

                        string pastaRelatorios =
                            Path.Combine(
                                Application.StartupPath,
                                "RelatoriosGerados");

                        Directory.CreateDirectory(
                            pastaRelatorios);


                        // =====================================================
                        // DEFINE O NOME DO PDF
                        // =====================================================

                        string arquivoPdf =
                            Path.Combine(
                                pastaRelatorios,
                                "RelatorioFinanceiro_" +
                                DateTime.Now.ToString(
                                    "yyyyMMdd_HHmmss") +
                                ".pdf");


                        // =====================================================
                        // EXPORTA PARA PDF
                        // =====================================================

                        using (PDFSimpleExport export =
                            new PDFSimpleExport())
                        {
                            report.Export(
                                export,
                                arquivoPdf);
                        }


                        // =====================================================
                        // ABRE O PDF
                        // =====================================================

                        Process.Start(
                            arquivoPdf);
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show(
                        "Erro ao gerar o relatório:\r\n\r\n" +
                        ex.Message,
                        "Relatório Financeiro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                }
                finally
                {
                    Cursor = Cursors.Default;
                }
            }

            private DataTable CriarDataTableRelatorio(
                List<RelatorioFinanceiroDto> registros)
            {
                var tabela =
                    new DataTable("Financeiro");

                tabela.Columns.Add(
                    "VendaId",
                    typeof(int));

                tabela.Columns.Add(
                    "DataVenda",
                    typeof(DateTime));

                tabela.Columns.Add(
                    "Cliente",
                    typeof(string));

                tabela.Columns.Add(
                    "Valor",
                    typeof(decimal));

                tabela.Columns.Add(
                    "Status",
                    typeof(string));

                tabela.Columns.Add(
                    "DataVencimento",
                    typeof(DateTime));

                tabela.Columns.Add(
                    "DataQuitacao",
                    typeof(DateTime));

                tabela.Columns.Add(
                    "DataCancelamento",
                    typeof(DateTime));

                tabela.Columns.Add(
                    "MotivoCancelamento",
                    typeof(string));

                foreach (var item in registros)
                {
                    var row =
                        tabela.NewRow();

                    row["VendaId"] =
                        item.VendaId;

                    row["DataVenda"] =
                        item.DataVenda;

                    row["Cliente"] =
                        item.Cliente ?? "";

                    row["Valor"] =
                        item.Valor;

                    row["Status"] =
                        item.Status ?? "";

                    row["DataVencimento"] =
                        item.DataVencimento.HasValue
                            ? (object)item.DataVencimento.Value
                            : DBNull.Value;

                    row["DataQuitacao"] =
                        item.DataQuitacao.HasValue
                            ? (object)item.DataQuitacao.Value
                            : DBNull.Value;

                    row["DataCancelamento"] =
                        item.DataCancelamento.HasValue
                            ? (object)item.DataCancelamento.Value
                            : DBNull.Value;

                    row["MotivoCancelamento"] =
                        string.IsNullOrWhiteSpace(
                            item.MotivoCancelamento)
                            ? (object)DBNull.Value
                            : item.MotivoCancelamento;

                    tabela.Rows.Add(row);
                }

                return tabela;
            }

            // =========================================================
            // QUITAR
            // =========================================================

            private FinanceiroDto Selecionado()
            {
                return _grid.CurrentRow?
                    .DataBoundItem as FinanceiroDto;
            }

            private void BtnQuitar_Click(
                object sender,
                EventArgs e)
            {
                var item =
                    Selecionado();

                if (item == null)
                {
                    MessageBox.Show(
                        "Selecione um registro.",
                        "ERP Financeiro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);

                    return;
                }

                if (item.Status == "QUITADA")
                {
                    MessageBox.Show(
                        "Este financeiro já está quitado.",
                        "ERP Financeiro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);

                    return;
                }

                if (item.Status == "CANCELADA")
                {
                    MessageBox.Show(
                        "Um financeiro cancelado não pode ser quitado.",
                        "ERP Financeiro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning);

                    return;
                }

                var confirmacao =
                    MessageBox.Show(
                        $"Confirmar quitação da venda {item.VendaId}?\r\n\r\n" +
                        $"Valor: {item.Valor:C}",
                        "Confirmar quitação",
                        MessageBoxButtons.YesNo,
                        MessageBoxIcon.Question);

                if (confirmacao !=
                    DialogResult.Yes)
                {
                    return;
                }

                ExecutarOperacao(
                    () => _api.Quitar(
                        item.VendaId),
                    "Financeiro quitado com sucesso.");
            }

            // =========================================================
            // CANCELAR
            // =========================================================

            private void BtnCancelar_Click(
                object sender,
                EventArgs e)
            {
                var item =
                    Selecionado();

                if (item == null)
                {
                    MessageBox.Show(
                        "Selecione um registro.",
                        "ERP Financeiro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);

                    return;
                }

                if (item.Status == "CANCELADA")
                {
                    MessageBox.Show(
                        "Este financeiro já está cancelado.",
                        "ERP Financeiro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);

                    return;
                }

                if (item.Status == "QUITADA")
                {
                    MessageBox.Show(
                        "Um financeiro quitado não pode ser cancelado.",
                        "ERP Financeiro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning);

                    return;
                }

                string motivo;

                if (!SolicitarMotivo(
                    out motivo))
                {
                    return;
                }

                ExecutarOperacao(
                    () => _api.Cancelar(
                        item.VendaId,
                        motivo),
                    "Financeiro cancelado com sucesso.");
            }

            // =========================================================
            // OPERAÇÃO
            // =========================================================

            private void ExecutarOperacao(
                Func<ApiResult> operacao,
                string sucesso)
            {
                Cursor =
                    Cursors.WaitCursor;

                try
                {
                    var resultado =
                        operacao();

                    if (!resultado.Success)
                    {
                        MessageBox.Show(
                            resultado.Message,
                            "ERP Financeiro",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Warning);

                        return;
                    }

                    MessageBox.Show(
                        sucesso,
                        "ERP Financeiro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);

                    CarregarFinanceiro();
                }
                catch (Exception ex)
                {
                    MessageBox.Show(
                        "Erro ao executar operação:\r\n\r\n" +
                        ex.Message,
                        "ERP Financeiro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                }
                finally
                {
                    Cursor =
                        Cursors.Default;
                }
            }

            // =========================================================
            // MOTIVO
            // =========================================================

            private bool SolicitarMotivo(
                out string motivo)
            {
                motivo = null;

                using (var form = new Form())
                using (var txt = new TextBox())
                using (var lbl = new Label())
                using (var btnOk = new Button())
                using (var btnCancelar = new Button())
                {
                    form.Text =
                        "Cancelar financeiro";

                    form.StartPosition =
                        FormStartPosition.CenterParent;

                    form.FormBorderStyle =
                        FormBorderStyle.FixedDialog;

                    form.MinimizeBox = false;
                    form.MaximizeBox = false;

                    form.ClientSize =
                        new Size(430, 190);

                    form.Font =
                        Font;

                    lbl.Text =
                        "Informe o motivo do cancelamento:";

                    lbl.AutoSize = true;

                    lbl.Location =
                        new Point(15, 15);

                    txt.Multiline = true;

                    txt.ScrollBars =
                        ScrollBars.Vertical;

                    txt.MaxLength = 500;

                    txt.Location =
                        new Point(15, 42);

                    txt.Size =
                        new Size(400, 85);

                    btnOk.Text =
                        "Confirmar";

                    btnOk.DialogResult =
                        DialogResult.OK;

                    btnOk.Location =
                        new Point(235, 140);

                    btnOk.Width = 85;

                    btnCancelar.Text =
                        "Cancelar";

                    btnCancelar.DialogResult =
                        DialogResult.Cancel;

                    btnCancelar.Location =
                        new Point(330, 140);

                    btnCancelar.Width = 85;

                    form.AcceptButton =
                        btnOk;

                    form.CancelButton =
                        btnCancelar;

                    form.Controls.AddRange(
                        new Control[]
                        {
                            lbl,
                            txt,
                            btnOk,
                            btnCancelar
                        });

                    if (form.ShowDialog(this) !=
                        DialogResult.OK)
                    {
                        return false;
                    }

                    if (string.IsNullOrWhiteSpace(
                        txt.Text))
                    {
                        MessageBox.Show(
                            "Informe o motivo do cancelamento.",
                            "ERP Financeiro",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Warning);

                        return false;
                    }

                    motivo =
                        txt.Text.Trim();

                    return true;
                }
            }

            // =========================================================
            // LIMPAR
            // =========================================================

            private void BtnLimpar_Click(
                object sender,
                EventArgs e)
            {
                _txtVenda.Clear();

                _cmbStatus.SelectedIndex =
                    0;

                _dtInicio.Checked =
                    false;

                _dtFim.Checked =
                    false;

                AplicarFiltros();
            }

            // =========================================================
            // VENDA
            // =========================================================

            private void TxtVenda_KeyPress(
                object sender,
                KeyPressEventArgs e)
            {
                if (!char.IsControl(e.KeyChar) &&
                    !char.IsDigit(e.KeyChar))
                {
                    e.Handled = true;
                }
            }

            // =========================================================
            // DETALHES
            // =========================================================

            private void Grid_CellDoubleClick(
                object sender,
                DataGridViewCellEventArgs e)
            {
                if (e.RowIndex < 0)
                    return;

                var item =
                    Selecionado();

                if (item == null)
                    return;

                MessageBox.Show(
                    $"Financeiro #{item.Id}\r\n" +
                    $"Venda: {item.VendaId}\r\n" +
                    $"Valor: {item.Valor:C}\r\n" +
                    $"Status: {item.Status}\r\n" +
                    $"Vencimento: " +
                    $"{(item.DataVencimento.HasValue ? item.DataVencimento.Value.ToString("dd/MM/yyyy") : "-")}\r\n" +
                    $"Quitação: " +
                    $"{(item.DataQuitacao.HasValue ? item.DataQuitacao.Value.ToString("dd/MM/yyyy HH:mm") : "-")}\r\n" +
                    $"Cancelamento: " +
                    $"{(item.DataCancelamento.HasValue ? item.DataCancelamento.Value.ToString("dd/MM/yyyy HH:mm") : "-")}\r\n" +
                    $"Motivo: " +
                    $"{item.MotivoCancelamento ?? "-"}",
                    "Detalhes do financeiro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }

            // =========================================================
            // FORMATAÇÃO
            // =========================================================

            private void Grid_CellFormatting(
                object sender,
                DataGridViewCellFormattingEventArgs e)
            {
                if (_grid.Columns[e.ColumnIndex]
                        .DataPropertyName != "Status" ||
                    e.Value == null)
                {
                    return;
                }

                string status =
                    e.Value.ToString();

                if (status == "QUITADA")
                {
                    e.CellStyle.Font =
                        new Font(
                            _grid.Font,
                            FontStyle.Bold);
                }
                else if (status == "CANCELADA")
                {
                    e.CellStyle.Font =
                        new Font(
                            _grid.Font,
                            FontStyle.Strikeout);
                }
            }
        }
    }   