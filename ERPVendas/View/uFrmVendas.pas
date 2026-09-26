unit uFrmVendas;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  Vcl.Buttons,
  FireDAC.Comp.Client,
  uVenda,
  uVendaItem,
  uVendaRepository,
  uVendaService,
  uVendaController,
  uFinanceiroServiceIntf,
  uFinanceiroApiService,
  uDMConexao,
  uDMRelatorioVenda;

type
  TFrmSelecionarCliente = class(TForm)
  private
    FQuery: TFDQuery;
    FRepo: TVendaRepository;
    FGrid: TStringGrid;
    FSelecionadoID: Integer;
    procedure GridDblClick(Sender: TObject);
    procedure BtnSelecionarClick(Sender: TObject);
    procedure Carregar;
  public
    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy; override;
    property SelecionadoID: Integer read FSelecionadoID;
  end;

  TFrmSelecionarProduto = class(TForm)
  private
    FQuery: TFDQuery;
    FRepo: TVendaRepository;
    FGrid: TStringGrid;
    FSelecionadoID: Integer;
    FSelecionadoNome: string;
    FSelecionadoPreco: Currency;
    procedure GridDblClick(Sender: TObject);
    procedure BtnSelecionarClick(Sender: TObject);
    procedure Carregar;
    procedure SelecionarLinha;
  public
    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy; override;
    property SelecionadoID: Integer read FSelecionadoID;
    property SelecionadoNome: string read FSelecionadoNome;
    property SelecionadoPreco: Currency read FSelecionadoPreco;
  end;

  TFrmVendas = class(TForm)
    PnlHeader: TPanel;
    PnlToolbar: TPanel;
    PnlInput: TPanel;
    PnlGrid: TPanel;
    PnlFooter: TPanel;
    LblTitle: TLabel;
    LblHint: TLabel;
    LblCliente: TLabel;
    LblProdutoID: TLabel;
    LblProduto: TLabel;
    LblQtd: TLabel;
    LblTotal: TLabel;
    LblConn: TLabel;
    EdtCliente: TEdit;
    BtnSelecionarCliente: TSpeedButton;
    EdtProdutoID: TEdit;
    EdtProduto: TEdit;
    BtnSelecionarProduto: TSpeedButton;
    EdtQtd: TEdit;
    BtnAdicionarItem: TSpeedButton;
    Grid: TStringGrid;
    BtnGravar: TButton;
    BtnLimpar: TButton;
    BtnCancelar: TButton;
    BtnFechar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnAdicionarItemClick(Sender: TObject);
    procedure BtnSelecionarClienteClick(Sender: TObject);
    procedure BtnSelecionarProdutoClick(Sender: TObject);
    procedure BtnGravarClick(Sender: TObject);
    procedure BtnLimparClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnFecharClick(Sender: TObject);
    procedure EdtQtdKeyPress(Sender: TObject; var Key: Char);
    procedure GridDblClick(Sender: TObject);
    procedure EdtProdutoIDKeyPress(Sender: TObject; var Key: Char);
    procedure EdtProdutoIDExit(Sender: TObject);
  private
    FVenda: TVenda;
    FRepo: TVendaRepository;
    FService: TVendaService;
    FController: TVendaController;
    FFinanceiroService: IFinanceiroService;
    FClienteSelecionadoID: Integer;
    FEditandoItemIndex: Integer;
    procedure AtualizarTotal;
    procedure LimparVenda;
    procedure LimparCamposItem;
    procedure SelecionarCliente;
    procedure SelecionarProduto;
    procedure LocalizarProdutoPorTexto;
    function CarregarProduto(AProdutoID: Integer): Boolean;
    procedure PreencherProduto(AID: Integer; const ANome: string; APreco: Currency);
    procedure AdicionarOuAtualizarItem;
    procedure AtualizarGrid;
    procedure CarregarItemSelecionado;
    procedure GerarRelatorioVenda(const AVendaID: Integer);
  end;

var
  FrmVendas: TFrmVendas;

implementation

{$R *.dfm}

{ TFrmSelecionarCliente }

constructor TFrmSelecionarCliente.Create(AOwner: TComponent);
var
  Btn: TButton;
  Lbl: TLabel;
begin
  inherited CreateNew(AOwner);
  Caption := 'Selecionar cliente';
  BorderStyle := bsDialog;
  BorderIcons := [biSystemMenu];
  Position := poOwnerFormCenter;
  ClientWidth := 620;
  ClientHeight := 430;
  Color := 2467481;
  Font.Name := 'Segoe UI';
  Font.Size := 9;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := 20;
  Lbl.Top := 16;
  Lbl.Caption := 'Selecione o cliente da venda';
  Lbl.Font.Style := [fsBold];
  Lbl.Font.Size := 12;
  Lbl.Font.Color := 2763306;

  FGrid := TStringGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.Left := 20;
  FGrid.Top := 48;
  FGrid.Width := 580;
  FGrid.Height := 325;
  FGrid.ColCount := 3;
  FGrid.FixedRows := 1;
  FGrid.RowCount := 2;
  FGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine,
    goHorzLine, goRowSelect, goColSizing];
  FGrid.Cells[0, 0] := 'ID';
  FGrid.Cells[1, 0] := 'Nome';
  FGrid.Cells[2, 0] := 'CPF/CNPJ';
  FGrid.OnDblClick := GridDblClick;
  FGrid.ColWidths[0] := 60;
  FGrid.ColWidths[1] := 340;
  FGrid.ColWidths[2] := 170;

  Btn := TButton.Create(Self);
  Btn.Parent := Self;
  Btn.Left := 500;
  Btn.Top := 383;
  Btn.Width := 100;
  Btn.Height := 32;
  Btn.Caption := 'Selecionar';
  Btn.Default := True;
  Btn.OnClick := BtnSelecionarClick;

  FRepo := TVendaRepository.Create(DMConexao.FDConnection);
  Carregar;
end;

destructor TFrmSelecionarCliente.Destroy;
begin
  FQuery.Free;
  FRepo.Free;
  inherited;
end;

procedure TFrmSelecionarCliente.Carregar;
var
  I: Integer;
begin
  DMConexao.GarantirConexao;
  FreeAndNil(FQuery);
  FQuery := FRepo.ListarClientesAtivos;

  FGrid.RowCount := FQuery.RecordCount + 1;
  I := 1;
  while not FQuery.Eof do
  begin
    FGrid.Cells[0, I] := FQuery.FieldByName('id').AsString;
    FGrid.Cells[1, I] := FQuery.FieldByName('nome').AsString;
    FGrid.Cells[2, I] := FQuery.FieldByName('cpf_cnpj').AsString;
    Inc(I);
    FQuery.Next;
  end;
  FQuery.First;
end;

procedure TFrmSelecionarCliente.BtnSelecionarClick(Sender: TObject);
begin
  if FGrid.Row <= 0 then
    Exit;
  FSelecionadoID := StrToIntDef(FGrid.Cells[0, FGrid.Row], 0);
  if FSelecionadoID > 0 then
    ModalResult := mrOk;
end;

procedure TFrmSelecionarCliente.GridDblClick(Sender: TObject);
begin
  BtnSelecionarClick(Sender);
end;

{ TFrmSelecionarProduto }

constructor TFrmSelecionarProduto.Create(AOwner: TComponent);
var
  Btn: TButton;
  Lbl: TLabel;
begin
  inherited CreateNew(AOwner);
  Caption := 'Selecionar produto';
  BorderStyle := bsDialog;
  BorderIcons := [biSystemMenu];
  Position := poOwnerFormCenter;
  ClientWidth := 720;
  ClientHeight := 450;
  Color := 2467481;
  Font.Name := 'Segoe UI';
  Font.Size := 9;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := 20;
  Lbl.Top := 16;
  Lbl.Caption := 'Selecione o produto da venda';
  Lbl.Font.Style := [fsBold];
  Lbl.Font.Size := 12;
  Lbl.Font.Color := 2763306;

  FGrid := TStringGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.Left := 20;
  FGrid.Top := 48;
  FGrid.Width := 680;
  FGrid.Height := 345;
  FGrid.ColCount := 4;
  FGrid.FixedRows := 1;
  FGrid.RowCount := 2;
  FGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine,
    goHorzLine, goRowSelect, goColSizing];
  FGrid.Cells[0, 0] := 'ID';
  FGrid.Cells[1, 0] := 'Código';
  FGrid.Cells[2, 0] := 'Descrição';
  FGrid.Cells[3, 0] := 'Preço';
  FGrid.OnDblClick := GridDblClick;
  FGrid.ColWidths[0] := 60;
  FGrid.ColWidths[1] := 110;
  FGrid.ColWidths[2] := 350;
  FGrid.ColWidths[3] := 120;

  Btn := TButton.Create(Self);
  Btn.Parent := Self;
  Btn.Left := 600;
  Btn.Top := 405;
  Btn.Width := 100;
  Btn.Height := 32;
  Btn.Caption := 'Selecionar';
  Btn.Default := True;
  Btn.OnClick := BtnSelecionarClick;

  FRepo := TVendaRepository.Create(DMConexao.FDConnection);
  Carregar;
end;

destructor TFrmSelecionarProduto.Destroy;
begin
  FQuery.Free;
  FRepo.Free;
  inherited;
end;

procedure TFrmSelecionarProduto.Carregar;
var
  I: Integer;
begin
  DMConexao.GarantirConexao;
  FreeAndNil(FQuery);
  FQuery := FRepo.ListarProdutosAtivos;

  FGrid.RowCount := FQuery.RecordCount + 1;
  I := 1;
  while not FQuery.Eof do
  begin
    FGrid.Cells[0, I] := FQuery.FieldByName('id').AsString;
    FGrid.Cells[1, I] := FQuery.FieldByName('codigo').AsString;
    FGrid.Cells[2, I] := FQuery.FieldByName('descricao').AsString;
    FGrid.Cells[3, I] := CurrToStrF(FQuery.FieldByName('preco').AsCurrency, ffNumber, 2);
    Inc(I);
    FQuery.Next;
  end;
end;

procedure TFrmSelecionarProduto.SelecionarLinha;
begin
  if FGrid.Row <= 0 then
    Exit;

  FSelecionadoID := StrToIntDef(FGrid.Cells[0, FGrid.Row], 0);
  FSelecionadoNome := FGrid.Cells[2, FGrid.Row];
  FSelecionadoPreco := StrToCurrDef(FGrid.Cells[3, FGrid.Row], 0);

  if FSelecionadoID > 0 then
    ModalResult := mrOk;
end;

procedure TFrmSelecionarProduto.BtnSelecionarClick(Sender: TObject);
begin
  SelecionarLinha;
end;

procedure TFrmSelecionarProduto.GridDblClick(Sender: TObject);
begin
  SelecionarLinha;
end;

{ TFrmVendas }

procedure TFrmVendas.FormCreate(Sender: TObject);
begin
  FRepo := TVendaRepository.Create(DMConexao.FDConnection);
  FFinanceiroService := TFinanceiroApiService.Create;
  FService := TVendaService.Create(
    FRepo,
    FFinanceiroService
  );
  FController := TVendaController.Create(FService);
  FVenda := TVenda.Create;
  FClienteSelecionadoID := 0;
  FEditandoItemIndex := -1;

  Grid.ColCount := 4;
  Grid.RowCount := 1;
  Grid.Cells[0, 0] := 'Produto ID';
  Grid.Cells[1, 0] := 'Quantidade';
  Grid.Cells[2, 0] := 'Valor unitário';
  Grid.Cells[3, 0] := 'Total';

  LblConn.Caption := 'Banco desconectado';

  try
    DMConexao.GarantirConexao;
    LblConn.Caption := 'Banco conectado';
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;

  AtualizarTotal;
end;

procedure TFrmVendas.FormDestroy(Sender: TObject);
begin
  FVenda.Free;
  FController.Free;
  FFinanceiroService := nil;
  FService.Free;
  FRepo.Free;
end;

procedure TFrmVendas.AtualizarTotal;
begin
  LblTotal.Caption := 'Total: R$ ' +
    CurrToStrF(FVenda.ValorTotal, ffNumber, 2);
end;

procedure TFrmVendas.LimparCamposItem;
begin
  EdtProdutoID.Clear;
  EdtProduto.Clear;
  EdtQtd.Clear;
  FEditandoItemIndex := -1;
  BtnAdicionarItem.Caption := '+';
  BtnAdicionarItem.Hint := 'Adicionar item';
  EdtProdutoID.SetFocus;
end;

procedure TFrmVendas.AtualizarGrid;
var
  I: Integer;
  Item: TVendaItem;
begin
  Grid.RowCount := FVenda.Itens.Count + 1;

  for I := 0 to FVenda.Itens.Count - 1 do
  begin
    Item := FVenda.Itens[I];
    Grid.Cells[0, I + 1] := IntToStr(Item.ProdutoID);
    Grid.Cells[1, I + 1] := FloatToStr(Item.Quantidade);
    Grid.Cells[2, I + 1] := CurrToStrF(Item.ValorUnitario, ffNumber, 2);
    Grid.Cells[3, I + 1] := CurrToStrF(Item.Total, ffNumber, 2);
  end;

  AtualizarTotal;
end;

procedure TFrmVendas.LimparVenda;
begin
  FreeAndNil(FVenda);
  FVenda := TVenda.Create;
  FClienteSelecionadoID := 0;
  EdtCliente.Clear;
  LimparCamposItem;
  Grid.RowCount := 1;
  AtualizarTotal;
end;

procedure TFrmVendas.SelecionarCliente;
var
  Modal: TFrmSelecionarCliente;
  Q: TFDQuery;
begin
  Modal := TFrmSelecionarCliente.Create(Self);
  try
    if Modal.ShowModal <> mrOk then
      Exit;

    FClienteSelecionadoID := Modal.SelecionadoID;
    Q := FRepo.ObterCliente(FClienteSelecionadoID);
    try
      if not Q.IsEmpty then
        EdtCliente.Text := Q.FieldByName('nome').AsString + ' - ' +
          Q.FieldByName('cpf_cnpj').AsString;
    finally
      Q.Free;
    end;
  finally
    Modal.Free;
  end;
end;

procedure TFrmVendas.BtnSelecionarClienteClick(Sender: TObject);
begin
  try
    SelecionarCliente;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmVendas.PreencherProduto(AID: Integer; const ANome: string;
  APreco: Currency);
begin
  EdtProdutoID.Text := IntToStr(AID);
  EdtProduto.Text := ANome;
  EdtProduto.Tag := AID;
  EdtQtd.SetFocus;
end;

procedure TFrmVendas.SelecionarProduto;
var
  Modal: TFrmSelecionarProduto;
begin
  Modal := TFrmSelecionarProduto.Create(Self);
  try
    if Modal.ShowModal = mrOk then
      PreencherProduto(Modal.SelecionadoID, Modal.SelecionadoNome,
        Modal.SelecionadoPreco);
  finally
    Modal.Free;
  end;
end;

procedure TFrmVendas.BtnSelecionarProdutoClick(Sender: TObject);
begin
  try
    SelecionarProduto;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

function TFrmVendas.CarregarProduto(AProdutoID: Integer): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;
  Q := FRepo.ObterProduto(AProdutoID);
  try

    if Q.IsEmpty then
      Exit;

    PreencherProduto(
      Q.FieldByName('id').AsInteger,
      Q.FieldByName('descricao').AsString,
      Q.FieldByName('preco').AsCurrency);
    Result := True;
  finally
    Q.Free;
  end;
end;

procedure TFrmVendas.LocalizarProdutoPorTexto;
var
  Id: Integer;
begin
  Id := StrToIntDef(Trim(EdtProdutoID.Text), 0);
  if Id <= 0 then
    Exit;

  DMConexao.GarantirConexao;

  if not CarregarProduto(Id) then
  begin
    EdtProdutoID.Clear;
    EdtProduto.Clear;
    MessageDlg(
      'Não foi possível localizar o produto informado.',
      mtInformation,
      [mbOK],
      0
    );
  end;
end;

procedure TFrmVendas.EdtProdutoIDExit(Sender: TObject);
begin
  if Trim(EdtProdutoID.Text) <> '' then
    LocalizarProdutoPorTexto;
end;

procedure TFrmVendas.EdtProdutoIDKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    LocalizarProdutoPorTexto;
  end;
end;

procedure TFrmVendas.AdicionarOuAtualizarItem;
var
  Q: TFDQuery;
  Item: TVendaItem;
  ProdutoID: Integer;
  Quantidade: Double;
  Preco: Currency;
begin
  DMConexao.GarantirConexao;

  ProdutoID := StrToIntDef(EdtProdutoID.Text, 0);
  Quantidade := StrToFloatDef(EdtQtd.Text, 0);

  if ProdutoID <= 0 then
    raise Exception.Create('Selecione um produto válido.');

  if Quantidade <= 0 then
    raise Exception.Create('Informe uma quantidade válida.');

  Q := FRepo.ObterProduto(ProdutoID);
  try

    if Q.IsEmpty then
      raise Exception.Create('Produto não encontrado ou inativo.');

    Preco := Q.FieldByName('preco').AsCurrency;

    if FEditandoItemIndex >= 0 then
    begin
      Item := FVenda.Itens[FEditandoItemIndex];
      Item.ProdutoID := ProdutoID;
      Item.Quantidade := Quantidade;
      Item.ValorUnitario := Preco;
    end
    else
    begin
      Item := TVendaItem.Create;
      Item.ProdutoID := ProdutoID;
      Item.Quantidade := Quantidade;
      Item.ValorUnitario := Preco;
      FVenda.Itens.Add(Item);
    end;

    FService.Recalcular(FVenda);
    AtualizarGrid;
    LimparCamposItem;
  finally
    Q.Free;
  end;
end;

procedure TFrmVendas.BtnAdicionarItemClick(Sender: TObject);
begin
  try
    AdicionarOuAtualizarItem;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmVendas.EdtQtdKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    BtnAdicionarItemClick(BtnAdicionarItem);
  end;
end;

procedure TFrmVendas.CarregarItemSelecionado;
var
  Index: Integer;
  Item: TVendaItem;
  Q: TFDQuery;
begin
  if Grid.Row <= 0 then
    Exit;

  Index := Grid.Row - 1;
  if (Index < 0) or (Index >= FVenda.Itens.Count) then
    Exit;

  Item := FVenda.Itens[Index];
  FEditandoItemIndex := Index;
  EdtProdutoID.Text := IntToStr(Item.ProdutoID);
  EdtQtd.Text := FloatToStr(Item.Quantidade);

  Q := FRepo.ObterProduto(Item.ProdutoID);
  try
    if not Q.IsEmpty then
      EdtProduto.Text := Q.FieldByName('descricao').AsString
    else
      EdtProduto.Clear;
  finally
    Q.Free;
  end;

  BtnAdicionarItem.Caption := 'Atualizar';
  BtnAdicionarItem.Hint := 'Atualizar item';
  EdtQtd.SetFocus;
end;

procedure TFrmVendas.GerarRelatorioVenda(const AVendaID: Integer);
var
  LRelatorio: TDMRelatorioVenda;
begin
  if AVendaID <= 0 then
    Exit;

  LRelatorio := TDMRelatorioVenda.Create(Self);
  try
    LRelatorio.VisualizarVenda(AVendaID);
  finally
    LRelatorio.Free;
  end;
end;

procedure TFrmVendas.GridDblClick(Sender: TObject);
begin
  CarregarItemSelecionado;
end;

procedure TFrmVendas.BtnGravarClick(Sender: TObject);
var
  LVendaID: Integer;
begin
  try
    DMConexao.GarantirConexao;

    if FClienteSelecionadoID <= 0 then
      raise Exception.Create('Selecione o cliente da venda.');

    if FVenda.Itens.Count = 0 then
      raise Exception.Create(
        'Adicione pelo menos um item à venda.');

    FVenda.ClienteID := FClienteSelecionadoID;

    FController.Gravar(FVenda);

    LVendaID := FVenda.ID;

    ShowMessage(
      'Venda gravada com sucesso. Nº ' +
      IntToStr(LVendaID));

    if MessageDlg(
      'Deseja gerar o relatório de confirmação da venda?',
      mtConfirmation,
      [mbYes, mbNo],
      0
    ) = mrYes then
    begin
      try
        GerarRelatorioVenda(LVendaID);
      except
        on E: Exception do
          MessageDlg(
            'A venda foi gravada, porém não foi possível gerar o relatório.' +
            sLineBreak + sLineBreak +
            E.Message,
            mtError,
            [mbOK],
            0
          );
      end;
    end;

    LimparVenda;

  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmVendas.BtnLimparClick(Sender: TObject);
begin
  LimparVenda;
end;

procedure TFrmVendas.BtnCancelarClick(Sender: TObject);
begin
  LimparVenda;
end;

procedure TFrmVendas.BtnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
