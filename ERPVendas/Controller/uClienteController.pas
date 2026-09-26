unit uClienteController;
interface

uses
  uCliente,
  uClienteService;

type
  TClienteController = class
  private
    FService: TClienteService;
  public
    constructor Create(AService: TClienteService);
    procedure Salvar(ACliente: TCliente);
    procedure Inativar(AID: Integer);
  end;

implementation

constructor TClienteController.Create(AService: TClienteService);
begin
  FService := AService;
end;

procedure TClienteController.Salvar(ACliente: TCliente);
begin
  FService.Salvar(ACliente);
end;

procedure TClienteController.Inativar(AID: Integer);
begin
  FService.Inativar(AID);
end;

end.