unit uProdutoRepository;
interface

uses
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  uProduto;

type
  TProdutoRepository = class
  private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);
    function Listar(sFiltro: String): TFDQuery;
    procedure Inserir(A: TProduto);
    procedure Atualizar(A: TProduto);
    procedure Inativar(AID: Integer);
    function QuantidadeProdutosAtivos: Integer;
    procedure AlterarStatus(AID: Integer; AAtivo: Boolean);
  end;

implementation

constructor TProdutoRepository.Create(AConnection: TFDConnection);
begin
  FConnection := AConnection;
end;

function TProdutoRepository.Listar(sFiltro: String): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  try
    Result.Connection := FConnection;
    Result.SQL.Text :=
      'SELECT id, codigo, descricao, preco, ativo ' +
    'FROM produto ' +
    'WHERE (:filtro = '''') ' +
    '   OR CAST(id AS TEXT) ILIKE :filtroLike ' +
    '   OR codigo ILIKE :filtroLike ' +
    '   OR descricao ILIKE :filtroLike ' +
    '   OR CAST(preco AS TEXT) ILIKE :filtroLike ' +
    '   OR ativo ILIKE :filtroLike ' +
    'ORDER BY descricao';

    Result.ParamByName('filtro').AsString := sFiltro;
    Result.ParamByName('filtroLike').AsString := '%' + sFiltro + '%';
    Result.Open;
  except
    Result.Free;
    raise;
  end;
end;

procedure TProdutoRepository.Inserir(A: TProduto);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'insert into produto (codigo, descricao, preco, ativo) ' +
      'values (:codigo, :descricao, :preco, ''S'')';
    Q.ParamByName('codigo').AsString := A.Codigo;
    Q.ParamByName('descricao').AsString := A.Descricao;
    Q.ParamByName('preco').AsCurrency := A.Preco;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TProdutoRepository.Atualizar(A: TProduto);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'update produto set codigo=:codigo, descricao=:descricao, ' +
      'preco=:preco, data_atualizacao=current_timestamp where id=:id';
    Q.ParamByName('codigo').AsString := A.Codigo;
    Q.ParamByName('descricao').AsString := A.Descricao;
    Q.ParamByName('preco').AsCurrency := A.Preco;
    Q.ParamByName('id').AsInteger := A.ID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TProdutoRepository.Inativar(AID: Integer);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'update produto set ativo=''N'', data_atualizacao=current_timestamp ' +
      'where id=:id';
    Q.ParamByName('id').AsInteger := AID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TProdutoRepository.AlterarStatus(AID: Integer; AAtivo: Boolean);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'UPDATE produto ' +
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


function TProdutoRepository.QuantidadeProdutosAtivos: Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'select count(*) as QUANTIDADE ' +
      'from produto where ativo = ''S''';
    Q.Open;
    Result := Q.FieldByName('QUANTIDADE').AsInteger;
  finally
    Q.Free;
  end;
end;

end.
