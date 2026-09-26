unit uProdutoService;

interface

uses
  System.SysUtils,
  uProduto,
  uProdutoRepository;

type
  TProdutoService = class
  private
    FRepository: TProdutoRepository;
  public
    constructor Create(ARepository: TProdutoRepository);
    procedure Salvar(AProduto: TProduto);
    procedure Inativar(AID: Integer);
  end;

implementation

constructor TProdutoService.Create(ARepository: TProdutoRepository);
begin
  if not Assigned(ARepository) then
    raise EArgumentNilException.Create(
      'ARepository não pode ser nulo.'
    );

  FRepository := ARepository;
end;

procedure TProdutoService.Salvar(AProduto: TProduto);
begin
  if not Assigned(AProduto) then
    raise Exception.Create('Produto não informado.');

  if Trim(AProduto.Codigo) = '' then
    raise Exception.Create('Código do produto é obrigatório.');

  if Trim(AProduto.Descricao) = '' then
    raise Exception.Create('Descrição do produto é obrigatória.');

  if AProduto.Preco < 0 then
    raise Exception.Create('Preço não pode ser negativo.');

  if AProduto.Ativo = '' then
    AProduto.Ativo := 'S';

  if AProduto.ID = 0 then
    FRepository.Inserir(AProduto)
  else
    FRepository.Atualizar(AProduto);
end;

procedure TProdutoService.Inativar(AID: Integer);
begin
  if AID <= 0 then
    raise Exception.Create('Produto inválido.');

  FRepository.Inativar(AID);
end;

end.
