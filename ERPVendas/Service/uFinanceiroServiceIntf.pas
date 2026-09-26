unit uFinanceiroServiceIntf;

interface

uses
  System.SysUtils;

type
  IFinanceiroService = interface
    ['{B9D6E2C1-7F2A-4C5E-9A41-6D8F3B2E7154}']
    procedure CriarFinanceiro(
      AVendaID: Integer;
      AValor: Currency;
      ADataVenda: TDateTime
    );
  end;

implementation

end.
