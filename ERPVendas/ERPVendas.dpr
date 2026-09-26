program ERPVendas;

uses
  Vcl.Forms,
  FireDAC.Stan.Def,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.DApt,
  FireDAC.Comp.Client,
  FireDAC.Comp.UI,
  FireDAC.VCLUI.Wait,
  FireDAC.Phys,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  FireDAC.Stan.Async,
  uDMConexao in 'Data\uDMConexao.pas' {DMConexao: TDataModule},
  uCliente in 'Model\uCliente.pas',
  uProduto in 'Model\uProduto.pas',
  uVenda in 'Model\uVenda.pas',
  uVendaItem in 'Model\uVendaItem.pas',
  uClienteRepository in 'Repository\uClienteRepository.pas',
  uProdutoRepository in 'Repository\uProdutoRepository.pas',
  uVendaRepository in 'Repository\uVendaRepository.pas',
  uClienteService in 'Service\uClienteService.pas',
  uProdutoService in 'Service\uProdutoService.pas',
  uVendaService in 'Service\uVendaService.pas',
  uClienteController in 'Controller\uClienteController.pas',
  uProdutoController in 'Controller\uProdutoController.pas',
  uVendaController in 'Controller\uVendaController.pas',
  uFrmPrincipal in 'View\uFrmPrincipal.pas' {FrmPrincipal},
  uFrmClientes in 'View\uFrmClientes.pas' {FrmClientes},
  uFrmProdutos in 'View\uFrmProdutos.pas' {FrmProdutos},
  uFrmVendas in 'View\uFrmVendas.pas' {FrmVendas},
  uFinanceiroApiService in 'Service\uFinanceiroApiService.pas',
  uDMRelatorioVenda in 'Data\uDMRelatorioVenda.pas' {DataModule1: TDataModule},
  uFinanceiroServiceIntf in 'Service\uFinanceiroServiceIntf.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'CARTSYS - ERP de Vendas';

  Application.CreateForm(TDMConexao, DMConexao);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TDMRelatorioVenda, DMRelatorioVenda);
  Application.Run;
end.
