unit uVendaItem;
interface

type
  TVendaItem = class
  private
    FID: Integer;
    FProdutoID: Integer;
    FQuantidade: Double;
    FValorUnitario: Currency;
  public
    function Total: Currency;
    property ID: Integer read FID write FID;
    property ProdutoID: Integer read FProdutoID write FProdutoID;
    property Quantidade: Double read FQuantidade write FQuantidade;
    property ValorUnitario: Currency read FValorUnitario write FValorUnitario;
  end;

implementation

function TVendaItem.Total: Currency;
begin
  Result := Quantidade * ValorUnitario;
end;

end.
