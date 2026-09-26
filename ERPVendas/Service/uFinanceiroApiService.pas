unit uFinanceiroApiService;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Net.URLClient,
  System.Net.HttpClient,
  System.DateUtils,
  uFinanceiroServiceIntf;

type
  TFinanceiroApiService = class(TInterfacedObject, IFinanceiroService)
  private
    FBaseURL: string;
    function DataVencimentoISO(const AData: TDateTime): string;
  public
    constructor Create(const ABaseURL: string = 'http://localhost:5000');
    procedure CriarFinanceiro(
      AVendaID: Integer;
      AValor: Currency;
      ADataVenda: TDateTime
    );
  end;

implementation

constructor TFinanceiroApiService.Create(const ABaseURL: string);
begin
  inherited Create;
  FBaseURL := ABaseURL.TrimRight(['/']);
end;

function TFinanceiroApiService.DataVencimentoISO(
  const AData: TDateTime): string;
begin
  Result := FormatDateTime(
    'yyyy-mm-dd',
    IncDay(AData, 30)
  );
end;

procedure TFinanceiroApiService.CriarFinanceiro(
  AVendaID: Integer;
  AValor: Currency;
  ADataVenda: TDateTime
);
var
  LClient: THTTPClient;
  LContent: TStringStream;
  LResponse: IHTTPResponse;
  LJson: TJSONObject;
  LURL: string;
begin
  if AVendaID <= 0 then
    raise Exception.Create(
      'Não foi possível criar o financeiro: venda inválida.'
    );

  if AValor < 0 then
    raise Exception.Create(
      'Não foi possível criar o financeiro: valor inválido.'
    );

  if ADataVenda <= 0 then
    raise Exception.Create(
      'Não foi possível criar o financeiro: data da venda inválida.'
    );

  LURL := FBaseURL + '/api/financeiro';

  LJson := TJSONObject.Create;
  try
    LJson.AddPair(
      'vendaId',
      TJSONNumber.Create(AVendaID)
    );

    LJson.AddPair(
      'valor',
      TJSONNumber.Create(AValor)
    );

    LJson.AddPair(
      'dataVencimento',
      DataVencimentoISO(ADataVenda)
    );

    LContent := TStringStream.Create(
      LJson.ToJSON,
      TEncoding.UTF8
    );
    try
      LClient := THTTPClient.Create;
      try
        LClient.ContentType := 'application/json';

        LResponse := LClient.Post(
          LURL,
          LContent
        );

        if (LResponse.StatusCode < 200) or
           (LResponse.StatusCode >= 300) then
        begin
          raise Exception.CreateFmt(
            'A API financeira retornou HTTP %d.%s%s',
            [
              LResponse.StatusCode,
              sLineBreak,
              LResponse.ContentAsString(TEncoding.UTF8)
            ]
          );
        end;
      finally
        LClient.Free;
      end;
    finally
      LContent.Free;
    end;
  finally
    LJson.Free;
  end;
end;

end.
