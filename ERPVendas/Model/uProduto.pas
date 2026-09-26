unit uProduto;
interface

type
  TProduto = class
  private
    FID: Integer;
    FCodigo: string;
    FDescricao: string;
    FPreco: Currency;
    FAtivo: string;
  public
    property ID: Integer read FID write FID;
    property Codigo: string read FCodigo write FCodigo;
    property Descricao: string read FDescricao write FDescricao;
    property Preco: Currency read FPreco write FPreco;
    property Ativo: string read FAtivo write FAtivo;
  end;

implementation
end.
