unit uDMRelatorioVenda;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Graphics,
  Data.DB,
  FireDAC.Comp.Client,
  ppDB,
  ppDBPipe,
  ppReport,
  ppClass,
  ppBands,
  ppCtrls,
  ppPrnabl,
  ppTypes,
  uDMConexao, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, ppParameter, ppDesignLayer, ppCache, ppProd,
  ppComm, ppRelatv, FireDAC.Comp.DataSet;

type
  TDMRelatorioVenda = class(TDataModule)
    QRelatorioVenda: TFDQuery;
    DSRelatorioVenda: TDataSource;
    plRelatorioVenda: TppDBPipeline;
    ppRelatorioVenda: TppReport;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure ConfigurarConsulta;
    procedure GarantirBandas;
    procedure ConfigurarRelatorio;
    function AddLabel(ABand: TppBand; const ACaption: string;
      ALeft, ATop, AWidth, AHeight: Integer; AFontSize: Integer = 10;
      ABold: Boolean = False): TppLabel;
    function AddDBText(ABand: TppBand; const AField: string;
      ALeft, ATop, AWidth, AHeight: Integer; AFontSize: Integer = 10;
      const ADisplayFormat: string = ''): TppDBText;
  public
    procedure AbrirVenda(const AVendaID: Integer);
    procedure VisualizarVenda(const AVendaID: Integer);
  end;

var
  DMRelatorioVenda: TDMRelatorioVenda;

implementation

{%CLASSGROUP 'Vcl.Controls'}

{$R *.dfm}

procedure TDMRelatorioVenda.DataModuleCreate(Sender: TObject);
begin
  QRelatorioVenda.Connection := DMConexao.FDConnection;
  DSRelatorioVenda.DataSet := QRelatorioVenda;
  plRelatorioVenda.DataSource := DSRelatorioVenda;

  ConfigurarConsulta;
  ConfigurarRelatorio;
end;

procedure TDMRelatorioVenda.ConfigurarConsulta;
begin
  QRelatorioVenda.SQL.Text :=
    'SELECT ' +
    '    v.id AS venda_id, ' +
    '    v.data_venda, ' +
    '    v.status, ' +
    '    v.observacao, ' +
    '    v.valor_total, ' +
    '    c.id AS cliente_id, ' +
    '    c.nome AS cliente_nome, ' +
    '    c.cpf_cnpj AS cliente_cpf_cnpj, ' +
    '    c.email AS cliente_email, ' +
    '    c.telefone AS cliente_telefone, ' +
    '    vi.id AS item_id, ' +
    '    vi.quantidade, ' +
    '    vi.valor_unitario, ' +
    '    vi.valor_total AS item_valor_total, ' +
    '    p.codigo AS produto_codigo, ' +
    '    p.descricao AS produto_descricao ' +
    'FROM venda v ' +
    'INNER JOIN cliente c ON c.id = v.cliente_id ' +
    'INNER JOIN venda_item vi ON vi.venda_id = v.id ' +
    'INNER JOIN produto p ON p.id = vi.produto_id ' +
    'WHERE v.id = :venda_id ' +
    'ORDER BY vi.id';
end;

function TDMRelatorioVenda.AddLabel(ABand: TppBand;
  const ACaption: string; ALeft, ATop, AWidth, AHeight: Integer;
  AFontSize: Integer; ABold: Boolean): TppLabel;
begin
  Result := TppLabel.Create(ppRelatorioVenda);
  Result.Band := ABand;
  Result.Caption := ACaption;
  Result.spLeft := ALeft;
  Result.spTop := ATop;
  Result.spWidth := AWidth;
  Result.spHeight := AHeight;
  Result.Font.Name := 'Arial';
  Result.Font.Size := AFontSize;

  if ABold then
    Result.Font.Style := [fsBold]
  else
    Result.Font.Style := [];
end;

function TDMRelatorioVenda.AddDBText(ABand: TppBand;
  const AField: string; ALeft, ATop, AWidth, AHeight: Integer;
  AFontSize: Integer; const ADisplayFormat: string): TppDBText;
begin
  Result := TppDBText.Create(ppRelatorioVenda);
  Result.Band := ABand;
  Result.DataPipeline := plRelatorioVenda;
  Result.DataField := AField;
  Result.spLeft := ALeft;
  Result.spTop := ATop;
  Result.spWidth := AWidth;
  Result.spHeight := AHeight;
  Result.Font.Name := 'Arial';
  Result.Font.Size := AFontSize;
  Result.Font.Style := [];

  if ADisplayFormat <> '' then
    Result.DisplayFormat := ADisplayFormat;
end;

procedure TDMRelatorioVenda.GarantirBandas;
var
  LBand: TppBand;
begin
  if not Assigned(ppRelatorioVenda.TitleBand) then
  begin
    LBand := TppTitleBand.Create(ppRelatorioVenda);
    LBand.Report := ppRelatorioVenda;
  end;

  if not Assigned(ppRelatorioVenda.HeaderBand) then
  begin
    LBand := TppHeaderBand.Create(ppRelatorioVenda);
    LBand.Report := ppRelatorioVenda;
  end;

  if not Assigned(ppRelatorioVenda.DetailBand) then
  begin
    LBand := TppDetailBand.Create(ppRelatorioVenda);
    LBand.Report := ppRelatorioVenda;
  end;

  if not Assigned(ppRelatorioVenda.FooterBand) then
  begin
    LBand := TppFooterBand.Create(ppRelatorioVenda);
    LBand.Report := ppRelatorioVenda;
  end;
end;

procedure TDMRelatorioVenda.ConfigurarRelatorio;
var
  LLabel: TppLabel;
  LDBText: TppDBText;
begin
  ppRelatorioVenda.DataPipeline := plRelatorioVenda;
  ppRelatorioVenda.AllowPrintToFile := True;
  ppRelatorioVenda.ShowPrintDialog := False;
  ppRelatorioVenda.ShowCancelDialog := False;
  ppRelatorioVenda.DeviceType := 'Screen';

  GarantirBandas;

  ppRelatorioVenda.DetailBand.Visible := True;

  { ============================================================
    BANDAS
    ============================================================ }
  ppRelatorioVenda.TitleBand.spHeight := 315;
  ppRelatorioVenda.DetailBand.spHeight := 28;
  ppRelatorioVenda.FooterBand.spHeight := 90;

  { ============================================================
    CABECALHO PRINCIPAL
    ============================================================ }

  LLabel := AddLabel(
    ppRelatorioVenda.TitleBand,
    'ERP VENDAS',
    40, 12, 680, 25, 17, True
  );
  LLabel.Alignment := taCenter;

  LLabel := AddLabel(
    ppRelatorioVenda.TitleBand,
    'CONFIRMACAO DE VENDA',
    40, 39, 680, 22, 12, True
  );
  LLabel.Alignment := taCenter;

  LLabel := AddLabel(
    ppRelatorioVenda.TitleBand,
    'Documento de confirmacao de venda',
    40, 63, 680, 18, 8, False
  );
  LLabel.Alignment := taCenter;

  { ============================================================
    DADOS DA VENDA
    ============================================================ }

  AddLabel(
    ppRelatorioVenda.TitleBand,
    'DADOS DA VENDA',
    40, 94, 680, 20, 11, True
  );

  { Primeira linha }
  AddLabel(
    ppRelatorioVenda.TitleBand,
    'Venda:',
    40, 121, 45, 18, 9, True
  );

  AddDBText(
    ppRelatorioVenda.TitleBand,
    'venda_id',
    88, 121, 70, 18, 9
  );

  AddLabel(
    ppRelatorioVenda.TitleBand,
    'Data:',
    190, 121, 40, 18, 9, True
  );

  AddDBText(
    ppRelatorioVenda.TitleBand,
    'data_venda',
    233, 121, 170, 18, 9,
    'dd/mm/yyyy hh:nn'
  );

  AddLabel(
    ppRelatorioVenda.TitleBand,
    'Status:',
    470, 121, 45, 18, 9, True
  );

  AddDBText(
    ppRelatorioVenda.TitleBand,
    'status',
    518, 121, 200, 18, 9
  );

  { Segunda linha }
  AddLabel(
    ppRelatorioVenda.TitleBand,
    'Valor:',
    470, 147, 45, 18, 9, True
  );

  LDBText := AddDBText(
    ppRelatorioVenda.TitleBand,
    'valor_total',
    518, 147, 200, 18, 9,
    'R$ #,##0.00'
  );
  LDBText.Alignment := taRightJustify;

  { ============================================================
    DADOS DO CLIENTE
    ============================================================ }

  AddLabel(
    ppRelatorioVenda.TitleBand,
    'DADOS DO CLIENTE',
    40, 180, 680, 20, 11, True
  );

  { Nome }
  AddLabel(
    ppRelatorioVenda.TitleBand,
    'Nome:',
    40, 207, 45, 18, 9, True
  );

  AddDBText(
    ppRelatorioVenda.TitleBand,
    'cliente_nome',
    88, 207, 630, 18, 9
  );

  { CPF/CNPJ }
  AddLabel(
    ppRelatorioVenda.TitleBand,
    'CPF/CNPJ:',
    40, 233, 70, 18, 9, True
  );

  AddDBText(
    ppRelatorioVenda.TitleBand,
    'cliente_cpf_cnpj',
    113, 233, 180, 18, 9
  );

  { E-mail }
  AddLabel(
    ppRelatorioVenda.TitleBand,
    'E-mail:',
    340, 233, 45, 18, 9, True
  );

  AddDBText(
    ppRelatorioVenda.TitleBand,
    'cliente_email',
    388, 233, 330, 18, 9
  );

  { Telefone }
  AddLabel(
    ppRelatorioVenda.TitleBand,
    'Telefone:',
    40, 259, 60, 18, 9, True
  );

  AddDBText(
    ppRelatorioVenda.TitleBand,
    'cliente_telefone',
    103, 259, 200, 18, 9
  );

  { ============================================================
    ITENS DA VENDA
    ============================================================ }

  AddLabel(
    ppRelatorioVenda.TitleBand,
    'ITENS DA VENDA',
    40, 287, 680, 20, 11, True
  );

  { Cabecalho da grade }
  AddLabel(
    ppRelatorioVenda.TitleBand,
    'Codigo',
    40, 309, 75, 18, 8, True
  );

  AddLabel(
    ppRelatorioVenda.TitleBand,
    'Produto',
    125, 309, 290, 18, 8, True
  );

  LLabel := AddLabel(
    ppRelatorioVenda.TitleBand,
    'Qtd.',
    420, 309, 55, 18, 8, True
  );
  LLabel.Alignment := taRightJustify;

  LLabel := AddLabel(
    ppRelatorioVenda.TitleBand,
    'Unitario',
    485, 309, 105, 18, 8, True
  );
  LLabel.Alignment := taRightJustify;

  LLabel := AddLabel(
    ppRelatorioVenda.TitleBand,
    'Total',
    600, 309, 118, 18, 8, True
  );
  LLabel.Alignment := taRightJustify;

  { ============================================================
    LINHAS DOS ITENS
    ============================================================ }

  AddDBText(
    ppRelatorioVenda.DetailBand,
    'produto_codigo',
    40, 4, 75, 20, 8
  );

  AddDBText(
    ppRelatorioVenda.DetailBand,
    'produto_descricao',
    125, 4, 290, 20, 8
  );

  LDBText := AddDBText(
    ppRelatorioVenda.DetailBand,
    'quantidade',
    420, 4, 55, 20, 8,
    '#,##0.###'
  );
  LDBText.Alignment := taRightJustify;

  LDBText := AddDBText(
    ppRelatorioVenda.DetailBand,
    'valor_unitario',
    485, 4, 105, 20, 8,
    'R$ #,##0.00'
  );
  LDBText.Alignment := taRightJustify;

  LDBText := AddDBText(
    ppRelatorioVenda.DetailBand,
    'item_valor_total',
    600, 4, 118, 20, 8,
    'R$ #,##0.00'
  );
  LDBText.Alignment := taRightJustify;

  { ============================================================
    RODAPE / TOTAL
    ============================================================ }

  AddLabel(
    ppRelatorioVenda.FooterBand,
    'TOTAL DA VENDA:',
    455, 12, 135, 22, 10, True
  );

  LDBText := AddDBText(
    ppRelatorioVenda.FooterBand,
    'valor_total',
    590, 10, 128, 25, 11,
    'R$ #,##0.00'
  );
  LDBText.Font.Style := [fsBold];
  LDBText.Alignment := taRightJustify;

  LLabel := AddLabel(
    ppRelatorioVenda.FooterBand,
    'Obrigado pela preferencia!',
    40, 50, 680, 18, 9, False
  );
  LLabel.Alignment := taCenter;

  LLabel := AddLabel(
    ppRelatorioVenda.FooterBand,
    'Documento gerado automaticamente pelo ERP Vendas.',
    40, 68, 680, 16, 8, False
  );
  LLabel.Alignment := taCenter;
end;

procedure TDMRelatorioVenda.AbrirVenda(const AVendaID: Integer);
begin
  if AVendaID <= 0 then
    raise Exception.Create('Informe uma venda valida para gerar o relatorio.');

  DMConexao.GarantirConexao;

  QRelatorioVenda.Close;
  QRelatorioVenda.ParamByName('venda_id').AsInteger := AVendaID;
  QRelatorioVenda.Open;
  QRelatorioVenda.FetchAll;
  QRelatorioVenda.First;

  if QRelatorioVenda.IsEmpty then
    raise Exception.CreateFmt(
      'A venda %d nao possui dados para gerar o relatorio.',
      [AVendaID]);

  plRelatorioVenda.AutoCreateFields := True;
  plRelatorioVenda.Open;
end;

procedure TDMRelatorioVenda.VisualizarVenda(const AVendaID: Integer);
begin
  AbrirVenda(AVendaID);
  ppRelatorioVenda.DeviceType := 'Screen';
  ppRelatorioVenda.Print;
end;

end.
