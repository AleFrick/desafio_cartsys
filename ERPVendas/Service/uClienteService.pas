unit uClienteService;

interface

uses
  System.SysUtils,
  uCliente,
  uClienteRepository;

type
  TClienteService = class
  private
    FRepository: TClienteRepository;
  public
    constructor Create(ARepository: TClienteRepository);
    procedure Salvar(ACliente: TCliente);
    procedure Inativar(AID: Integer);
    function QuantidadeClientesAtivos: Integer;
  end;

implementation

constructor TClienteService.Create(ARepository: TClienteRepository);
begin
  if not Assigned(ARepository) then
    raise EArgumentNilException.Create(
      'ARepository não pode ser nulo.'
    );

  FRepository := ARepository;
end;

procedure TClienteService.Salvar(ACliente: TCliente);
begin
  if not Assigned(ACliente) then
    raise Exception.Create('Cliente não informado.');

  if Trim(ACliente.Nome) = '' then
    raise Exception.Create('Nome do cliente é obrigatório.');

  if ACliente.Ativo = '' then
    ACliente.Ativo := 'S';

  if ACliente.ID = 0 then
    FRepository.Inserir(ACliente)
  else
    FRepository.Atualizar(ACliente);
end;

procedure TClienteService.Inativar(AID: Integer);
begin
  if AID <= 0 then
    raise Exception.Create('Cliente inválido.');

  FRepository.Inativar(AID);
end;

function TClienteService.QuantidadeClientesAtivos: Integer;
begin
  Result := FRepository.QuantidadeClientesAtivos;
end;

end.
