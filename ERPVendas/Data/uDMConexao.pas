unit uDMConexao;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,
  FireDAC.Comp.Client,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef;

type
  TDMConexao = class(TDataModule)
    FDConnection: TFDConnection;
    FDPhysPgDriverLink: TFDPhysPgDriverLink;
  private
    procedure ConfigurarConexao;
  public
    procedure Conectar;
    procedure Desconectar;
    function Conectado: Boolean;
    procedure GarantirConexao;
  end;

var
  DMConexao: TDMConexao;

implementation

{%CLASSGROUP 'Vcl.Controls'}

{$R *.dfm}

procedure TDMConexao.ConfigurarConexao;
var
  LIni: TIniFile;
  LArquivoConfig: string;
begin
  LArquivoConfig :=
    IncludeTrailingPathDelimiter(
      ExtractFilePath(ParamStr(0))
    ) + 'config.ini';

  if not FileExists(LArquivoConfig) then
    raise Exception.Create(
      'Arquivo config.ini não encontrado.' + sLineBreak + sLineBreak +
      'Arquivo esperado em:' + sLineBreak +
      LArquivoConfig
    );

  LIni := TIniFile.Create(LArquivoConfig);
  try
    FDConnection.LoginPrompt := False;
    FDConnection.Params.Clear;

    FDConnection.Params.Values['DriverID'] := 'PG';

    FDConnection.Params.Values['Server'] :=
      LIni.ReadString(
        'DATABASE',
        'Server',
        'localhost'
      );

    FDConnection.Params.Values['Port'] :=
      LIni.ReadString(
        'DATABASE',
        'Port',
        '5432'
      );

    FDConnection.Params.Values['Database'] :=
      LIni.ReadString(
        'DATABASE',
        'Database',
        'catsys'
      );

    FDConnection.Params.Values['User_Name'] :=
      LIni.ReadString(
        'DATABASE',
        'Username',
        'postgres'
      );

    FDConnection.Params.Values['Password'] :=
      LIni.ReadString(
        'DATABASE',
        'Password',
        'postgres'
      );
  finally
    LIni.Free;
  end;
end;

procedure TDMConexao.Conectar;
begin
  if Conectado then
    Exit;

  ConfigurarConexao;
  FDConnection.Connected := True;
end;

procedure TDMConexao.Desconectar;
begin
  if Conectado then
    FDConnection.Connected := False;
end;

function TDMConexao.Conectado: Boolean;
begin
  Result := Assigned(FDConnection) and FDConnection.Connected;
end;

procedure TDMConexao.GarantirConexao;
begin
  if Conectado then
    Exit;

  try
    Conectar;
  except
    on E: Exception do
      raise Exception.Create(
        'Não foi possível conectar ao banco de dados.' + sLineBreak +
        'A operação não foi realizada.' + sLineBreak + sLineBreak +
        E.Message);
  end;

  if not Conectado then
    raise Exception.Create(
      'A conexão com o banco de dados não está ativa.' + sLineBreak +
      'A operação não foi realizada.');
end;

end.
