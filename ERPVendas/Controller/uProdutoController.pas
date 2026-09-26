unit uProdutoController;
interface

uses
  uProduto,
  uProdutoService;

type
  TProdutoController = class
  private
    FService: TProdutoService;
  public
    constructor Create(AService: TProdutoService);
    procedure Salvar(AProduto: TProduto);
    procedure Inativar(AID: Integer);
  end;

implementation

constructor TProdutoController.Create(AService: TProdutoService);
begin
  FService := AService;
end;

procedure TProdutoController.Salvar(AProduto: TProduto);
begin
  FService.Salvar(AProduto);
end;

procedure TProdutoController.Inativar(AID: Integer);
begin
  FService.Inativar(AID);
end;

end.