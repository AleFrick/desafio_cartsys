unit uVenda;
interface

uses
  System.Generics.Collections, uVendaItem;

type
  TVenda = class
  private
    FID: Integer;
    FClienteID: Integer;
    FValorTotal: Currency;
    FStatus: string;
    FItens: TObjectList<TVendaItem>;
  public
    constructor Create;
    destructor Destroy; override;
    property ID: Integer read FID write FID;
    property ClienteID: Integer read FClienteID write FClienteID;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
    property Status: string read FStatus write FStatus;
    property Itens: TObjectList<TVendaItem> read FItens;
  end;

implementation

constructor TVenda.Create;
begin
  inherited;
  FItens := TObjectList<TVendaItem>.Create(True);
  FStatus := 'PENDENTE';
end;

destructor TVenda.Destroy;
begin
  FItens.Free;
  inherited;
end;

end.
