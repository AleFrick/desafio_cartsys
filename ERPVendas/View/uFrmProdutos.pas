unit uFrmProdutos;

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
  Vcl.DBGrids,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  FireDAC.Comp.Client,
  uProduto,
  uProdutoRepository,
  uProdutoService,
  uProdutoController,
  uDMConexao;

type
  TFrmProdutoModal = class(TForm)
  private
    FProduto: TProduto;
    FController: TProdutoController;
    LblTitulo: TLabel;
    LblCodigo: TLabel;
    LblDescricao: TLabel;
    LblPreco: TLabel;
    EdtCodigo: TEdit;
    EdtDescricao: TEdit;
    EdtPreco: TEdit;
    BtnSalvar: TButton;
    BtnCancelar: TButton;
    procedure BtnSalvarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure CriarInterface;
  public
    constructor Create(AOwner: TComponent; AController: TProdutoController;
      AProduto: TProduto); reintroduce;
  end;

  TFrmProdutos = class(TForm)
    PnlHeader: TPanel;
    PnlToolbar: TPanel;
    PnlGrid: TPanel;
    Grid: TDBGrid;
    DS: TDataSource;
    LblTitle: TLabel;
    LblHint: TLabel;
    BtnNovo: TButton;
    BtnInativar: TButton;
    EdtFiltro: TEdit;
    LblFiltro: TLabel;
    LblConn: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BtnNovoClick(Sender: TObject);
    procedure BtnInativarClick(Sender: TObject);
    procedure EdtFiltroChange(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure DSDataChange(Sender: TObject; Field: TField);
  private
    FQuery: TFDQuery;
    FRepo: TProdutoRepository;
    FService: TProdutoService;
    FController: TProdutoController;
    procedure Carregar(const AFiltro: string = '');
    procedure ConfigurarGrid;
    procedure AjustarColunasGrid;
    procedure AtualizarBotaoStatus;
    function AbrirModalProduto(AID: Integer): Boolean;
  end;

var
  FrmProdutos: TFrmProdutos;

implementation

{$R *.dfm}

constructor TFrmProdutoModal.Create(AOwner: TComponent;
  AController: TProdutoController; AProduto: TProduto);
begin
  inherited CreateNew(AOwner);
  FController := AController;
  FProduto := AProduto;
  CriarInterface;
end;

procedure TFrmProdutoModal.CriarInterface;
var
  PnlHeader: TPanel;
  PnlDados: TPanel;
  PnlBotoes: TPanel;
  LblTitulo: TLabel;
  LblCodigo: TLabel;
  LblDescricao: TLabel;
  LblPreco: TLabel;
  BtnSalvar: TButton;
  BtnCancelar: TButton;
begin
  Caption := 'Produto';
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 560;
  ClientHeight := 300;
  Color := 2467481;
  Font.Name := 'Segoe UI';
  Font.Size := 10;

  PnlHeader := TPanel.Create(Self);
  PnlHeader.Parent := Self;
  PnlHeader.Align := alTop;
  PnlHeader.Height := 68;
  PnlHeader.BevelOuter := bvNone;
  PnlHeader.Color := clWhite;
  PnlHeader.ParentBackground := False;

  LblTitulo := TLabel.Create(Self);
  LblTitulo.Parent := PnlHeader;
  LblTitulo.Left := 24;
  LblTitulo.Top := 10;
  LblTitulo.AutoSize := True;
  if FProduto.ID = 0 then
    LblTitulo.Caption := 'Novo produto'
  else
    LblTitulo.Caption := 'Editar produto';
  LblTitulo.Font.Name := 'Segoe UI';
  LblTitulo.Font.Size := 14;
  LblTitulo.Font.Style := [fsBold];
  LblTitulo.Font.Color := 2763306;

  PnlDados := TPanel.Create(Self);
  PnlDados.Parent := Self;
  PnlDados.Align := alClient;
  PnlDados.BevelOuter := bvNone;
  PnlDados.Color := 2467481;
  PnlDados.ParentBackground := False;

  LblCodigo := TLabel.Create(Self);
  LblCodigo.Parent := PnlDados;
  LblCodigo.Left := 24;
  LblCodigo.Top := 12;
  LblCodigo.Caption := 'Código';

  EdtCodigo := TEdit.Create(Self);
  EdtCodigo.Parent := PnlDados;
  EdtCodigo.Left := 24;
  EdtCodigo.Top := 33;
  EdtCodigo.Width := 245;
  EdtCodigo.Height := 27;
  EdtCodigo.TabOrder := 0;
  EdtCodigo.Text := FProduto.Codigo;

  LblDescricao := TLabel.Create(Self);
  LblDescricao.Parent := PnlDados;
  LblDescricao.Left := 291;
  LblDescricao.Top := 12;
  LblDescricao.Caption := 'Descrição';

  EdtDescricao := TEdit.Create(Self);
  EdtDescricao.Parent := PnlDados;
  EdtDescricao.Left := 291;
  EdtDescricao.Top := 33;
  EdtDescricao.Width := 245;
  EdtDescricao.Height := 27;
  EdtDescricao.TabOrder := 1;
  EdtDescricao.Text := FProduto.Descricao;

  LblPreco := TLabel.Create(Self);
  LblPreco.Parent := PnlDados;
  LblPreco.Left := 24;
  LblPreco.Top := 72;
  LblPreco.Caption := 'Preço';

  EdtPreco := TEdit.Create(Self);
  EdtPreco.Parent := PnlDados;
  EdtPreco.Left := 24;
  EdtPreco.Top := 93;
  EdtPreco.Width := 245;
  EdtPreco.Height := 27;
  EdtPreco.TabOrder := 2;
  EdtPreco.Text := CurrToStr(FProduto.Preco);

  PnlBotoes := TPanel.Create(Self);
  PnlBotoes.Parent := Self;
  PnlBotoes.Align := alBottom;
  PnlBotoes.Height := 54;
  PnlBotoes.BevelOuter := bvNone;
  PnlBotoes.Color := clWhite;
  PnlBotoes.ParentBackground := False;

  BtnCancelar := TButton.Create(Self);
  BtnCancelar.Parent := PnlBotoes;
  BtnCancelar.Caption := 'Cancelar';
  BtnCancelar.Left := 344;
  BtnCancelar.Top := 10;
  BtnCancelar.Width := 90;
  BtnCancelar.Height := 34;
  BtnCancelar.Cancel := True;
  BtnCancelar.ModalResult := mrCancel;

  BtnSalvar := TButton.Create(Self);
  BtnSalvar.Parent := PnlBotoes;
  BtnSalvar.Caption := 'Salvar';
  BtnSalvar.Left := 444;
  BtnSalvar.Top := 10;
  BtnSalvar.Width := 90;
  BtnSalvar.Height := 34;
  BtnSalvar.Default := True;
  BtnSalvar.OnClick := BtnSalvarClick;
end;

procedure TFrmProdutoModal.BtnSalvarClick(Sender: TObject);
begin
  try
    DMConexao.GarantirConexao;

    FProduto.Codigo := Trim(EdtCodigo.Text);
    FProduto.Descricao := Trim(EdtDescricao.Text);
    FProduto.Preco := StrToCurrDef(Trim(EdtPreco.Text), 0);

    FController.Salvar(FProduto);

    ModalResult := mrOk;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmProdutoModal.BtnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFrmProdutos.FormCreate(Sender: TObject);
begin
  FRepo := TProdutoRepository.Create(DMConexao.FDConnection);
  FService := TProdutoService.Create(FRepo);
  FController := TProdutoController.Create(FService);

  LblConn.Caption := 'Banco desconectado';

  try
    DMConexao.GarantirConexao;
    LblConn.Caption := 'Banco conectado';
    Carregar;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmProdutos.FormDestroy(Sender: TObject);
begin
  DS.DataSet := nil;
  FreeAndNil(FQuery);
  FreeAndNil(FController);
  FreeAndNil(FService);
  FreeAndNil(FRepo);
end;

procedure TFrmProdutos.FormResize(Sender: TObject);
begin
  AjustarColunasGrid;
end;

procedure TFrmProdutos.Carregar(const AFiltro: string);
begin
  DMConexao.GarantirConexao;

  FreeAndNil(FQuery);
  FQuery := FRepo.Listar(Trim(AFiltro));

  DS.DataSet := FQuery;
  ConfigurarGrid;
  AtualizarBotaoStatus;
  LblConn.Caption := 'Banco conectado';
end;

procedure TFrmProdutos.ConfigurarGrid;
var
  Col: TColumn;
begin
  if (FQuery = nil) or not FQuery.Active then
    Exit;

  Grid.Columns.Clear;

  Col := Grid.Columns.Add;
  Col.FieldName := 'id';
  Col.Title.Caption := 'Código';
  Col.Width := 70;

  Col := Grid.Columns.Add;
  Col.FieldName := 'codigo';
  Col.Title.Caption := 'Código produto';
  Col.Width := 150;

  Col := Grid.Columns.Add;
  Col.FieldName := 'descricao';
  Col.Title.Caption := 'Descrição';
  Col.Width := 350;

  Col := Grid.Columns.Add;
  Col.FieldName := 'preco';
  Col.Title.Caption := 'Preço';
  Col.Width := 140;

  Col := Grid.Columns.Add;
  Col.FieldName := 'ativo';
  Col.Title.Caption := 'Ativo';
  Col.Width := 90;

  AjustarColunasGrid;
end;

procedure TFrmProdutos.AjustarColunasGrid;
const
  Proporcoes: array[0..4] of Integer = (8, 17, 43, 20, 12);
var
  I: Integer;
  LarguraDisponivel: Integer;
  LarguraRestante: Integer;
begin
  if Grid.Columns.Count = 0 then
    Exit;

  LarguraDisponivel := Grid.ClientWidth - 28;
  if LarguraDisponivel < 300 then
    Exit;

  LarguraRestante := LarguraDisponivel;

  for I := 0 to Grid.Columns.Count - 2 do
  begin
    Grid.Columns[I].Width :=
      (LarguraDisponivel * Proporcoes[I]) div 100;
    Dec(LarguraRestante, Grid.Columns[I].Width);
  end;

  Grid.Columns[Grid.Columns.Count - 1].Width := LarguraRestante;

  if Grid.Columns[Grid.Columns.Count - 1].Width < 60 then
    Grid.Columns[Grid.Columns.Count - 1].Width := 60;
end;

procedure TFrmProdutos.AtualizarBotaoStatus;
begin
  if (FQuery = nil) or FQuery.IsEmpty then
  begin
    BtnInativar.Enabled := False;
    BtnInativar.Caption := 'Inativar';
    Exit;
  end;

  BtnInativar.Enabled := True;

  if SameText(FQuery.FieldByName('ativo').AsString, 'S') then
    BtnInativar.Caption := 'Inativar'
  else
    BtnInativar.Caption := 'Ativar';
end;

procedure TFrmProdutos.DSDataChange(Sender: TObject; Field: TField);
begin
  AtualizarBotaoStatus;
end;

procedure TFrmProdutos.BtnNovoClick(Sender: TObject);
begin
  AbrirModalProduto(0);
end;

function TFrmProdutos.AbrirModalProduto(AID: Integer): Boolean;
var
  Produto: TProduto;
  Modal: TFrmProdutoModal;
begin
  Result := False;

  Produto := TProduto.Create;
  try
    if AID > 0 then
    begin
      if (FQuery = nil) or FQuery.IsEmpty then
        Exit;

      Produto.ID := FQuery.FieldByName('id').AsInteger;
      Produto.Codigo := FQuery.FieldByName('codigo').AsString;
      Produto.Descricao := FQuery.FieldByName('descricao').AsString;
      Produto.Preco := FQuery.FieldByName('preco').AsCurrency;
      Produto.Ativo := FQuery.FieldByName('ativo').AsString;
    end;

    Modal := TFrmProdutoModal.Create(Self, FController, Produto);
    try
      Result := Modal.ShowModal = mrOk;
    finally
      Modal.Free;
    end;
  finally
    Produto.Free;
  end;

  if Result then
    Carregar(EdtFiltro.Text);
end;

procedure TFrmProdutos.GridDblClick(Sender: TObject);
begin
  if (FQuery = nil) or FQuery.IsEmpty then
    Exit;

  AbrirModalProduto(FQuery.FieldByName('id').AsInteger);
end;

procedure TFrmProdutos.BtnInativarClick(Sender: TObject);
var
  ID: Integer;
  Ativo: string;
  NovoStatus: Boolean;
  Acao: string;
begin
  try
    DMConexao.GarantirConexao;

    if (FQuery = nil) or FQuery.IsEmpty then
      Exit;

    ID := FQuery.FieldByName('id').AsInteger;
    Ativo := FQuery.FieldByName('ativo').AsString;
    NovoStatus := not SameText(Ativo, 'S');

    if NovoStatus then
      Acao := 'Ativar'
    else
      Acao := 'Inativar';

    if MessageDlg(
      Acao + ' o produto selecionado?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      FRepo.AlterarStatus(ID, NovoStatus);
      Carregar(EdtFiltro.Text);
    end;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmProdutos.EdtFiltroChange(Sender: TObject);
begin
  Carregar(EdtFiltro.Text);
end;

end.
