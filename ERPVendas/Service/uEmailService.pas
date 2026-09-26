unit uEmailService;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,
  IdSMTP,
  IdMessage,
  IdAttachmentFile,
  IdSSLOpenSSL,
  IdExplicitTLSClientServerBase;

type
  TEmailConfig = record
    Host: string;
    Port: Integer;
    Username: string;
    Password: string;
    FromEmail: string;
    FromName: string;
    UseSSL: Boolean;
  end;

  TEmailService = class
  private
    FConfig: TEmailConfig;
    procedure CarregarConfiguracao;
  public
    constructor Create;
    procedure EnviarEmail(const ADestinatario, ANomeDestinatario,
      AAssunto, ACorpo, AAnexo: string);
  end;

implementation

constructor TEmailService.Create;
begin
  inherited Create;
  CarregarConfiguracao;
end;

procedure TEmailService.CarregarConfiguracao;
var
  LArquivo: string;
  LIni: TIniFile;
begin
  LArquivo := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'config.ini';

  if not FileExists(LArquivo) then
    raise Exception.Create(
      'Arquivo config.ini nao encontrado.' + sLineBreak +
      'Crie o arquivo ao lado do executavel do ERP Vendas.');

  LIni := TIniFile.Create(LArquivo);
  try
    FConfig.Host := Trim(LIni.ReadString('SMTP', 'Host', 'localhost'));
    FConfig.Port := LIni.ReadInteger('SMTP', 'Port', 1025);
    FConfig.Username := LIni.ReadString('SMTP', 'Username', '');
    FConfig.Password := LIni.ReadString('SMTP', 'Password', '');
    FConfig.FromEmail := Trim(
      LIni.ReadString('SMTP', 'From', 'erpvendas@localhost'));
    FConfig.FromName := LIni.ReadString('SMTP', 'FromName', 'ERP Vendas');
    FConfig.UseSSL := SameText(
      Trim(LIni.ReadString('SMTP', 'UseSSL', 'N')), 'S');
  finally
    LIni.Free;
  end;

  if FConfig.Host = '' then
    raise Exception.Create('SMTP.Host nao configurado.');

  if FConfig.FromEmail = '' then
    raise Exception.Create('SMTP.From nao configurado.');
end;

procedure TEmailService.EnviarEmail(const ADestinatario,
  ANomeDestinatario, AAssunto, ACorpo, AAnexo: string);
var
  LSMTP: TIdSMTP;
  LMensagem: TIdMessage;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  if Trim(ADestinatario) = '' then
    raise Exception.Create('O cliente nao possui e-mail cadastrado.');

  if not FileExists(AAnexo) then
    raise Exception.CreateFmt('Anexo nao encontrado: %s', [AAnexo]);

  LSMTP := TIdSMTP.Create(nil);
  LMensagem := TIdMessage.Create(nil);
  LSSL := nil;
  try
    LSMTP.Host := FConfig.Host;
    LSMTP.Port := FConfig.Port;

    if FConfig.Username <> '' then
    begin
      LSMTP.Username := FConfig.Username;
      LSMTP.Password := FConfig.Password;
      LSMTP.AuthType := satDefault;
    end
    else
      LSMTP.AuthType := satNone;

    if FConfig.UseSSL then
    begin
      LSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      LSMTP.IOHandler := LSSL;
      LSMTP.UseTLS := utUseExplicitTLS;
    end
    else
      LSMTP.UseTLS := utNoTLSSupport;

    LMensagem.Clear;
    LMensagem.CharSet := 'utf-8';
    LMensagem.ContentType := 'text/plain';
    LMensagem.From.Address := FConfig.FromEmail;
    LMensagem.From.Name := FConfig.FromName;
    LMensagem.Recipients.EMailAddresses := ADestinatario;
    LMensagem.Subject := AAssunto;
    LMensagem.Body.Text := ACorpo;

    if ANomeDestinatario <> '' then
      LMensagem.Recipients[0].Name := ANomeDestinatario;

    TIdAttachmentFile.Create(LMensagem.MessageParts, AAnexo);

    LSMTP.Connect;
    try
      LSMTP.Send(LMensagem);
    finally
      if LSMTP.Connected then
        LSMTP.Disconnect;
    end;
  finally
    LSSL.Free;
    LMensagem.Free;
    LSMTP.Free;
  end;
end;

end.
