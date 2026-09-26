unit uConfirmacaoVendaService;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  FireDAC.Comp.Client,
  ppTypes,
  uDMConexao,
  uDMRelatorioVenda,
  uEmailService;

type
  TConfirmacaoVendaService = class
  private
    FEmailService: TEmailService;
    function ObterDadosCliente(const AVendaID: Integer;
      out ANome, AEmail: string): Boolean;
    function GerarPDF(const AVendaID: Integer): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure EnviarConfirmacao(const AVendaID: Integer);
  end;

implementation

constructor TConfirmacaoVendaService.Create;
begin
  inherited Create;
  FEmailService := TEmailService.Create;
end;

destructor TConfirmacaoVendaService.Destroy;
begin
  FEmailService.Free;
  inherited;
end;

function TConfirmacaoVendaService.ObterDadosCliente(
  const AVendaID: Integer; out ANome, AEmail: string): Boolean;
var
  LQuery: TFDQuery;
begin
  ANome := '';
  AEmail := '';

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := DMConexao.FDConnection;
    LQuery.SQL.Text :=
      'SELECT c.nome, c.email ' +
      'FROM venda v ' +
      'INNER JOIN cliente c ON c.id = v.cliente_id ' +
      'WHERE v.id = :venda_id ' +
      '  AND v.status = ''QUITADA''';

    LQuery.ParamByName('venda_id').AsInteger := AVendaID;
    LQuery.Open;

    Result := not LQuery.IsEmpty;

    if Result then
    begin
      ANome := LQuery.FieldByName('nome').AsString;
      AEmail := Trim(LQuery.FieldByName('email').AsString);
    end;
  finally
    LQuery.Free;
  end;
end;

function TConfirmacaoVendaService.GerarPDF(const AVendaID: Integer): string;
var
  LPasta: string;
begin
  LPasta := IncludeTrailingPathDelimiter(
    TPath.Combine(ExtractFilePath(ParamStr(0)), 'Relatorios'));

  ForceDirectories(LPasta);

  Result := TPath.Combine(
    LPasta,
    Format('Confirmacao_Venda_%d.pdf', [AVendaID])
  );

  DMRelatorioVenda.AbrirVenda(AVendaID);

  if FileExists(Result) then
    DeleteFile(Result);

  DMRelatorioVenda.ppRelatorioVenda.AllowPrintToFile := True;
  DMRelatorioVenda.ppRelatorioVenda.ShowPrintDialog := False;
  DMRelatorioVenda.ppRelatorioVenda.ShowCancelDialog := False;
  DMRelatorioVenda.ppRelatorioVenda.DeviceType := dtPDF;
  DMRelatorioVenda.ppRelatorioVenda.TextFileName := Result;
  DMRelatorioVenda.ppRelatorioVenda.PDFSettings.Author := 'ERP Vendas';
  DMRelatorioVenda.ppRelatorioVenda.PDFSettings.Title :=
    Format('Confirmacao da Venda %d', [AVendaID]);
  DMRelatorioVenda.ppRelatorioVenda.OpenFile := False;

  try
    DMRelatorioVenda.ppRelatorioVenda.Print;
  finally
    DMRelatorioVenda.ppRelatorioVenda.DeviceType := 'Screen';
    DMRelatorioVenda.ppRelatorioVenda.TextFileName := '';
  end;

  if not FileExists(Result) then
    raise Exception.Create(
      'O PDF da confirmacao da venda nao foi gerado.');
end;

procedure TConfirmacaoVendaService.EnviarConfirmacao(
  const AVendaID: Integer);
var
  LNomeCliente: string;
  LEmailCliente: string;
  LPDF: string;
begin
  if AVendaID <= 0 then
    raise Exception.Create('Venda invalida.');

  DMConexao.GarantirConexao;

  if not ObterDadosCliente(AVendaID, LNomeCliente, LEmailCliente) then
    raise Exception.CreateFmt(
      'A venda %d nao esta quitada ou nao foi encontrada.',
      [AVendaID]);

  if LEmailCliente = '' then
    raise Exception.CreateFmt(
      'O cliente da venda %d nao possui e-mail cadastrado.',
      [AVendaID]);

  LPDF := GerarPDF(AVendaID);

  FEmailService.EnviarEmail(
    LEmailCliente,
    LNomeCliente,
    Format('Confirmacao da venda #%d', [AVendaID]),
    Format(
      'Ola, %s.%s%sSegue em anexo o documento de confirmacao da venda #%d.%s%s' +
      'Obrigado pela preferencia.%s%sERP Vendas',
      [
        LNomeCliente,
        sLineBreak,
        sLineBreak,
        AVendaID,
        sLineBreak,
        sLineBreak,
        sLineBreak,
        sLineBreak
      ]
    ),
    LPDF
  );
end;

end.
