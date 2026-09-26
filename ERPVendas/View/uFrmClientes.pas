unit uFrmClientes;

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
  uCliente,
  uClienteRepository,
  uClienteService,
  uClienteController,
  uDMConexao;

type
  TFrmClienteModal = class(TForm)
  private
    FController: TClienteController;
    FCliente: TCliente;
    EdtNome: TEdit;
    EdtCPF: TEdit;
    EdtEmail: TEdit;
    EdtTelefone: TEdit;
    procedure BtnSalvarClick(Sender: TObject);
    procedure CriarInterface;
  public
    constructor Create(AOwner: TComponent; AController: TClienteController;
      ACliente: TCliente); reintroduce;
  end;

  TFrmClientes = class(TForm)
    PnlHeader: TPanel;
    PnlToolbar: TPanel;
    PnlGrid: TPanel;
    Grid: TDBGrid;
    DS: TDataSource;
    LblTitle: TLabel;
    LblHint: TLabel;
    BtnNovo: TButton;
    BtnInativar: TButton;
    LblConn: TLabel;
    LblFiltro: TLabel;
    EdtFiltro: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnNovoClick(Sender: TObject);
    procedure BtnInativarClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure EdtFiltroChange(Sender: TObject);
    procedure DSDataChange(Sender: TObject; Field: TField);
    procedure GridResize(Sender: TObject);
  private
    FQuery: TFDQuery;
    FRepo: TClienteRepository;
    FService: TClienteService;
    FController: TClienteController;
    procedure Carregar(const AFiltro: string = '');
    procedure ConfigurarGrid;
    procedure AjustarColunasGrid;
    procedure AtualizarBotaoStatus;
    function AbrirModalCliente(AID: Integer): Boolean;
  end;

var
  FrmClientes: TFrmClientes;

implementation

{$R *.dfm}

constructor TFrmClienteModal.Create(AOwner: TComponent;
  AController: TClienteController; ACliente: TCliente);
begin
  inherited CreateNew(AOwner);
  FController := AController;
  FCliente := ACliente;
  CriarInterface;
end;

procedure TFrmClienteModal.CriarInterface;
var
  PnlHeader: TPanel;
  PnlDados: TPanel;
  PnlBotoes: TPanel;
  LblTitulo: TLabel;
  LblNome: TLabel;
  LblCPF: TLabel;
  LblEmail: TLabel;
  LblTelefone: TLabel;
  BtnSalvar: TButton;
  BtnCancelar: TButton;
begin
  Caption := 'Cliente';
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
  if FCliente.ID = 0 then
    LblTitulo.Caption := 'Novo cliente'
  else
    LblTitulo.Caption := 'Editar cliente';
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

  LblNome := TLabel.Create(Self);
  LblNome.Parent := PnlDados;
  LblNome.Left := 24;
  LblNome.Top := 12;
  LblNome.Caption := 'Nome';

  EdtNome := TEdit.Create(Self);
  EdtNome.Parent := PnlDados;
  EdtNome.Left := 24;
  EdtNome.Top := 33;
  EdtNome.Width := 512;
  EdtNome.Height := 27;
  EdtNome.TabOrder := 0;
  EdtNome.Text := FCliente.Nome;

  LblCPF := TLabel.Create(Self);
  LblCPF.Parent := PnlDados;
  LblCPF.Left := 24;
  LblCPF.Top := 72;
  LblCPF.Caption := 'CPF/CNPJ';

  EdtCPF := TEdit.Create(Self);
  EdtCPF.Parent := PnlDados;
  EdtCPF.Left := 24;
  EdtCPF.Top := 93;
  EdtCPF.Width := 245;
  EdtCPF.Height := 27;
  EdtCPF.TabOrder := 1;
  EdtCPF.Text := FCliente.CPFCNPJ;

  LblTelefone := TLabel.Create(Self);
  LblTelefone.Parent := PnlDados;
  LblTelefone.Left := 291;
  LblTelefone.Top := 72;
  LblTelefone.Caption := 'Telefone';

  EdtTelefone := TEdit.Create(Self);
  EdtTelefone.Parent := PnlDados;
  EdtTelefone.Left := 291;
  EdtTelefone.Top := 93;
  EdtTelefone.Width := 245;
  EdtTelefone.Height := 27;
  EdtTelefone.TabOrder := 2;
  EdtTelefone.Text := FCliente.Telefone;

  LblEmail := TLabel.Create(Self);
  LblEmail.Parent := PnlDados;
  LblEmail.Left := 24;
  LblEmail.Top := 126;
  LblEmail.Caption := 'E-mail';

  EdtEmail := TEdit.Create(Self);
  EdtEmail.Parent := PnlDados;
  EdtEmail.Left := 24;
  EdtEmail.Top := 144;
  EdtEmail.Width := 512;
  EdtEmail.Height := 27;
  EdtEmail.TabOrder := 3;
  EdtEmail.Text := FCliente.Email;

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

  //EdtNome.SetFocus;
end;

procedure TFrmClienteModal.BtnSalvarClick(Sender: TObject);
begin
  try
    DMConexao.GarantirConexao;

    FCliente.Nome := Trim(EdtNome.Text);
    FCliente.CPFCNPJ := Trim(EdtCPF.Text);
    FCliente.Email := Trim(EdtEmail.Text);
    FCliente.Telefone := Trim(EdtTelefone.Text);

    FController.Salvar(FCliente);
    ModalResult := mrOk;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmClientes.FormCreate(Sender: TObject);
begin
  FRepo := TClienteRepository.Create(DMConexao.FDConnection);
  FService := TClienteService.Create(FRepo);
  FController := TClienteController.Create(FService);

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

procedure TFrmClientes.FormDestroy(Sender: TObject);
begin
  DS.DataSet := nil;
  FQuery.Free;
  FController.Free;
  FService.Free;
  FRepo.Free;
end;

procedure TFrmClientes.Carregar(const AFiltro: string);
begin
  DMConexao.GarantirConexao;

  FreeAndNil(FQuery);

  FQuery := FRepo.ListarComFiltro(Trim(AFiltro));

  DS.DataSet :=  FQuery;
  ConfigurarGrid;
  AtualizarBotaoStatus;
  LblConn.Caption := 'Banco conectado';
end;

procedure TFrmClientes.ConfigurarGrid;
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
  Col.FieldName := 'nome';
  Col.Title.Caption := 'Nome';
  Col.Width := 240;

  Col := Grid.Columns.Add;
  Col.FieldName := 'cpf_cnpj';
  Col.Title.Caption := 'CPF/CNPJ';
  Col.Width := 150;

  Col := Grid.Columns.Add;
  Col.FieldName := 'email';
  Col.Title.Caption := 'E-mail';
  Col.Width := 220;

  Col := Grid.Columns.Add;
  Col.FieldName := 'telefone';
  Col.Title.Caption := 'Telefone';
  Col.Width := 130;

  Col := Grid.Columns.Add;
  Col.FieldName := 'ativo';
  Col.Title.Caption := 'Ativo';
  Col.Width := 80;

  AjustarColunasGrid;
end;

procedure TFrmClientes.AjustarColunasGrid;
const
  Proporcoes: array[0..5] of Integer = (7, 25, 16, 25, 15, 12);
var
  I: Integer;
  LarguraDisponivel: Integer;
  LarguraRestante: Integer;
begin
  if Grid.Columns.Count = 0 then
    Exit;

  { Desconta o indicador de linha e uma pequena margem para evitar
    scrollbar horizontal. A última coluna recebe o restante. }
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

procedure TFrmClientes.GridResize(Sender: TObject);
begin
  AjustarColunasGrid;
end;

procedure TFrmClientes.AtualizarBotaoStatus;
var
  Ativo: string;
begin
  if (FQuery = nil) or FQuery.IsEmpty then
  begin
    BtnInativar.Enabled := False;
    BtnInativar.Caption := 'Inativar';
    Exit;
  end;

  BtnInativar.Enabled := True;
  Ativo := FQuery.FieldByName('ativo').AsString;

  if SameText(Ativo, 'S') then
    BtnInativar.Caption := 'Inativar'
  else
    BtnInativar.Caption := 'Ativar';
end;

procedure TFrmClientes.DSDataChange(Sender: TObject; Field: TField);
begin
  AtualizarBotaoStatus;
end;

function TFrmClientes.AbrirModalCliente(AID: Integer): Boolean;
var
  Frm: TFrmClienteModal;
  A: TCliente;
begin
  Result := False;
  A := TCliente.Create;
  try
    if (AID > 0) and (FQuery <> nil) and not FQuery.IsEmpty then
    begin
      A.ID := FQuery.FieldByName('id').AsInteger;
      A.Nome := FQuery.FieldByName('nome').AsString;
      A.CPFCNPJ := FQuery.FieldByName('cpf_cnpj').AsString;
      A.Email := FQuery.FieldByName('email').AsString;
      A.Telefone := FQuery.FieldByName('telefone').AsString;
      A.Ativo := FQuery.FieldByName('ativo').AsString;
    end
    else
    begin
      A.ID := 0;
      A.Ativo := 'S';
    end;

    Frm := TFrmClienteModal.Create(Self, FController, A);
    try
      Result := Frm.ShowModal = mrOk;
    finally
      Frm.Free;
    end;
  finally
    A.Free;
  end;
end;

procedure TFrmClientes.BtnNovoClick(Sender: TObject);
begin
  if AbrirModalCliente(0) then
  begin
    Carregar;
  end;
end;

procedure TFrmClientes.GridDblClick(Sender: TObject);
var
  ID: Integer;
begin
  try
    if (FQuery = nil) or FQuery.IsEmpty then
      Exit;

    ID := FQuery.FieldByName('id').AsInteger;

    if AbrirModalCliente(ID) then
    begin
      Carregar;
    end;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmClientes.EdtFiltroChange(Sender: TObject);
begin
  try
    Carregar(EdtFiltro.Text);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmClientes.BtnInativarClick(Sender: TObject);
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
      Acao + ' o cliente selecionado?',
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

end.
