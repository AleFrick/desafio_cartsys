unit uVendaController;

interface

uses
  System.SysUtils,
  uVenda,
  uVendaService;

type
  TVendaController = class
  private
    FService: TVendaService;
  public
    constructor Create(AService: TVendaService);
    procedure Gravar(AVenda: TVenda);
  end;

implementation

constructor TVendaController.Create(AService: TVendaService);
begin
  if not Assigned(AService) then
    raise EArgumentNilException.Create(
      'AService não pode ser nulo.'
    );

  FService := AService;
end;

procedure TVendaController.Gravar(AVenda: TVenda);
begin
  if not Assigned(AVenda) then
    raise EArgumentNilException.Create(
      'A venda não pode ser nula.'
    );

  FService.Gravar(AVenda);
end;

end.
