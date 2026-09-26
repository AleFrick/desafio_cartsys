unit uVendaService;

interface

uses
  System.SysUtils,
  uVenda,
  uVendaRepository,
  uFinanceiroServiceIntf;

type
  TVendaService = class
  private
    FRepository: TVendaRepository;
    FFinanceiroService: IFinanceiroService;
  public
    constructor Create(
      ARepository: TVendaRepository;
      AFinanceiroService: IFinanceiroService
    );

    procedure Gravar(AVenda: TVenda);
    procedure Recalcular(AVenda: TVenda);
    procedure Validar(AVenda: TVenda);
  end;

implementation

constructor TVendaService.Create(
  ARepository: TVendaRepository;
  AFinanceiroService: IFinanceiroService
);
begin
  if not Assigned(ARepository) then
    raise EArgumentNilException.Create(
      'ARepository não pode ser nulo.'
    );

  if not Assigned(AFinanceiroService) then
    raise EArgumentNilException.Create(
      'AFinanceiroService não pode ser nulo.'
    );

  FRepository := ARepository;
  FFinanceiroService := AFinanceiroService;
end;

procedure TVendaService.Gravar(AVenda: TVenda);
begin
  Validar(AVenda);
  Recalcular(AVenda);

  FRepository.Gravar(AVenda);

  try
    FFinanceiroService.CriarFinanceiro(
      AVenda.ID,
      AVenda.ValorTotal,
      Now
    );
  except
    on E: Exception do
      raise Exception.CreateFmt(
        'A venda %d foi gravada com sucesso, porém não foi possível ' +
        'criar o financeiro.%s%s',
        [
          AVenda.ID,
          sLineBreak,
          E.Message
        ]
      );
  end;
end;

procedure TVendaService.Recalcular(AVenda: TVenda);
var
  I: Integer;
begin
  if not Assigned(AVenda) then
    Exit;

  AVenda.ValorTotal := 0;

  for I := 0 to AVenda.Itens.Count - 1 do
    AVenda.ValorTotal :=
      AVenda.ValorTotal + AVenda.Itens[I].Total;
end;

procedure TVendaService.Validar(AVenda: TVenda);
begin
  if not Assigned(AVenda) then
    raise Exception.Create('Venda não informada.');

  if AVenda.ClienteID <= 0 then
    raise Exception.Create('Cliente da venda é obrigatório.');

  if AVenda.Itens.Count = 0 then
    raise Exception.Create(
      'A venda deve possuir pelo menos um item.'
    );
end;

end.
