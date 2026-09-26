unit uFrmPrincipal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  uDMConexao,
  uFrmClientes,
  uFrmProdutos,
  uFrmVendas,
  uClienteRepository,
  uProdutoRepository,
  uVendaRepository;

type
  TFrmPrincipal = class(TForm)
    PnlMenu: TPanel;
    LblLogo: TLabel;
    LblMenuCaption: TLabel;
    BtnInicio: TButton;
    BtnClientes: TButton;
    BtnProdutos: TButton;
    BtnVendas: TButton;
    BtnSair: TButton;
    PnlTop: TPanel;
    LblPageTitle: TLabel;
    LblPageSubtitle: TLabel;
    LblConnection: TLabel;
    BtnConectar: TButton;
    BtnDesconectar: TButton;
    PnlContent: TPanel;
    CardClientes: TPanel;
    LblCardClientes: TLabel;
    LblClientesValue: TLabel;
    CardProdutos: TPanel;
    LblCardProdutos: TLabel;
    LblProdutosValue: TLabel;
    CardVendas: TPanel;
    LblCardVendas: TLabel;
    LblVendasValue: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnInicioClick(Sender: TObject);
    procedure BtnClientesClick(Sender: TObject);
    procedure BtnProdutosClick(Sender: TObject);
    procedure BtnVendasClick(Sender: TObject);
    procedure BtnSairClick(Sender: TObject);
    procedure BtnConectarClick(Sender: TObject);
    procedure BtnDesconectarClick(Sender: TObject);
  private
    procedure AtualizarStatus;
    procedure AtualizarIndicadores;
    procedure AbrirFormulario(AFormulario: TForm);
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  AtualizarStatus;
  AtualizarIndicadores;
end;

procedure TFrmPrincipal.AtualizarStatus;
begin
  if DMConexao.Conectado then
  begin
    LblConnection.Caption := 'Banco conectado';
    LblConnection.Font.Color := clGreen;
  end
  else
  begin
    LblConnection.Caption := 'Banco desconectado';
    LblConnection.Font.Color := clRed;
  end;
end;

procedure TFrmPrincipal.AtualizarIndicadores;
var
  LClienteRepository: TClienteRepository;
  LProdutoRepository: TProdutoRepository;
  LVendaRepository: TVendaRepository;
begin
  if not DMConexao.Conectado then
  begin
    LblClientesValue.Caption := '-';
    LblProdutosValue.Caption := '-';
    LblVendasValue.Caption := '-';
    Exit;
  end;

  LClienteRepository := TClienteRepository.Create(DMConexao.FDConnection);
  LProdutoRepository := TProdutoRepository.Create(DMConexao.FDConnection);
  LVendaRepository := TVendaRepository.Create(DMConexao.FDConnection);
  try
    try
      LblClientesValue.Caption :=
        LClienteRepository.QuantidadeClientesAtivos.ToString;

      LblProdutosValue.Caption :=
        LProdutoRepository.QuantidadeProdutosAtivos.ToString;

      LblVendasValue.Caption :=
        LVendaRepository.QuantidadeVendas.ToString;
    except
      on E: Exception do
      begin
        LblClientesValue.Caption := '-';
        LblProdutosValue.Caption := '-';
        LblVendasValue.Caption := '-';

        MessageDlg(
          'Não foi possível atualizar os indicadores.' + sLineBreak + sLineBreak +
          E.Message,
          mtWarning,
          [mbOK],
          0
        );
      end;
    end;
  finally
    LVendaRepository.Free;
    LProdutoRepository.Free;
    LClienteRepository.Free;
  end;
end;

procedure TFrmPrincipal.AbrirFormulario(AFormulario: TForm);
begin
  if not Assigned(AFormulario) then
    Exit;

  try
    AFormulario.ShowModal;
  finally
    AFormulario.Free;
    AtualizarStatus;
    AtualizarIndicadores;
  end;
end;

procedure TFrmPrincipal.BtnInicioClick(Sender: TObject);
begin
  AtualizarStatus;
  AtualizarIndicadores;
end;

procedure TFrmPrincipal.BtnClientesClick(Sender: TObject);
begin
  AbrirFormulario(TFrmClientes.Create(Self));
end;

procedure TFrmPrincipal.BtnProdutosClick(Sender: TObject);
begin
  AbrirFormulario(TFrmProdutos.Create(Self));
end;

procedure TFrmPrincipal.BtnVendasClick(Sender: TObject);
begin
  AbrirFormulario(TFrmVendas.Create(Self));
end;

procedure TFrmPrincipal.BtnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPrincipal.BtnConectarClick(Sender: TObject);
begin
  try
    DMConexao.GarantirConexao;
    AtualizarStatus;
    AtualizarIndicadores;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmPrincipal.BtnDesconectarClick(Sender: TObject);
begin
  try
    DMConexao.Desconectar;
    AtualizarStatus;
    AtualizarIndicadores;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

end.
  