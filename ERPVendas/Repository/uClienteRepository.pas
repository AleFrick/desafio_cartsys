unit uClienteRepository;

interface

uses
  FireDAC.Comp.Client,
  uCliente;

type
  TClienteRepository = class
  private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);
    function Listar: TFDQuery;
    function ListarComFiltro(sFiltro: String): TFDQuery;
    procedure Inserir(A: TCliente);
    procedure Atualizar(A: TCliente);
    procedure Inativar(AID: Integer);
    procedure AlterarStatus(AID: Integer; AAtivo: Boolean);
    function QuantidadeClientesAtivos: Integer;
  end;

implementation

constructor TClienteRepository.Create(AConnection: TFDConnection);
begin
  FConnection := AConnection;
end;

function TClienteRepository.Listar: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  try
    Result.Connection := FConnection;
    Result.SQL.Text :=
      'select id, nome, cpf_cnpj, email, telefone, ativo ' +
      'from cliente order by nome';
    Result.Open;
  except
    Result.Free;
    raise;
  end;
end;

function TClienteRepository.ListarComFiltro(sFiltro: String): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  try
    Result.Connection := FConnection;
    Result.SQL.Text :=
      'SELECT id, nome, cpf_cnpj, email, telefone, ativo ' +
      'FROM cliente ' +
      'WHERE CAST(id AS TEXT) ILIKE :filtro ' +
      '   OR nome ILIKE :filtro ' +
      '   OR cpf_cnpj ILIKE :filtro ' +
      '   OR email ILIKE :filtro ' +
      '   OR telefone ILIKE :filtro ' +
      '   OR ativo ILIKE :filtro ' +
      'ORDER BY id';
    Result.ParamByName('filtro').AsString := '%' + sFiltro + '%';
    Result.Open;
  except
    Result.Free;
    raise;
  end;
end;

function TClienteRepository.QuantidadeClientesAtivos: Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'select count(*) as QUANTIDADE from cliente where ativo = ''S''';
    Q.Open;

    Result := Q.FieldByName('QUANTIDADE').AsInteger;
  finally
    Q.Free;
  end;
end;

procedure TClienteRepository.Inserir(A: TCliente);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'insert into cliente (nome, cpf_cnpj, email, telefone, ativo) ' +
      'values (:nome, :cpf, :email, :tel, ''S'')';
    Q.ParamByName('nome').AsString := A.Nome;
    Q.ParamByName('cpf').AsString := A.CPFCNPJ;
    Q.ParamByName('email').AsString := A.Email;
    Q.ParamByName('tel').AsString := A.Telefone;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TClienteRepository.Atualizar(A: TCliente);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'update cliente set nome=:nome, cpf_cnpj=:cpf, email=:email, ' +
      'telefone=:tel, data_atualizacao=current_timestamp where id=:id';
    Q.ParamByName('nome').AsString := A.Nome;
    Q.ParamByName('cpf').AsString := A.CPFCNPJ;
    Q.ParamByName('email').AsString := A.Email;
    Q.ParamByName('tel').AsString := A.Telefone;
    Q.ParamByName('id').AsInteger := A.ID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TClienteRepository.Inativar(AID: Integer);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'update cliente set ativo=''N'', data_atualizacao=current_timestamp ' +
      'where id=:id';
    Q.ParamByName('id').AsInteger := AID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TClienteRepository.AlterarStatus(AID: Integer; AAtivo: Boolean);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'UPDATE cliente ' +
      'SET ativo = :ativo, data_atualizacao = CURRENT_TIMESTAMP ' +
      'WHERE id = :id';

    if AAtivo then
      Q.ParamByName('ativo').AsString := 'S'
    else
      Q.ParamByName('ativo').AsString := 'N';

    Q.ParamByName('id').AsInteger := AID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
