unit uVendaRepository;
interface

uses
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  uVenda;

type
  TVendaRepository = class
  private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);
    procedure Gravar(A: TVenda);
    procedure Cancelar(AID: Integer);
    function QuantidadeVendas: Integer;
    function ListarClientesAtivos: TFDQuery;
    function ObterCliente(AID: Integer): TFDQuery;
    function ListarProdutosAtivos: TFDQuery;
    function ObterProduto(AID: Integer): TFDQuery;
  end;

implementation

constructor TVendaRepository.Create(AConnection: TFDConnection);
begin
  FConnection := AConnection;
end;

procedure TVendaRepository.Gravar(A: TVenda);
var
  Q: TFDQuery;
  I: Integer;
begin
  FConnection.StartTransaction;
  try
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := FConnection;

      Q.SQL.Text :=
        'insert into venda (cliente_id, valor_total, status) ' +
        'values (:cliente, :total, ''PENDENTE'') returning id';
      Q.ParamByName('cliente').AsInteger := A.ClienteID;
      Q.ParamByName('total').AsCurrency := A.ValorTotal;
      Q.Open;
      A.ID := Q.FieldByName('id').AsInteger;
      Q.Close;

      for I := 0 to A.Itens.Count - 1 do
      begin
        Q.SQL.Text :=
          'insert into venda_item ' +
          '(venda_id, produto_id, quantidade, valor_unitario, valor_total) ' +
          'values (:venda, :produto, :qtd, :unit, :total)';

        Q.ParamByName('venda').AsInteger := A.ID;
        Q.ParamByName('produto').AsInteger := A.Itens[I].ProdutoID;
        Q.ParamByName('qtd').AsFloat := A.Itens[I].Quantidade;
        Q.ParamByName('unit').AsCurrency := A.Itens[I].ValorUnitario;
        Q.ParamByName('total').AsCurrency := A.Itens[I].Total;
        Q.ExecSQL;
      end;
    finally
      Q.Free;
    end;

    FConnection.Commit;
  except
    if FConnection.InTransaction then
      FConnection.Rollback;
    raise;
  end;
end;

procedure TVendaRepository.Cancelar(AID: Integer);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'update venda set status=''CANCELADA'' ' +
      'where id=:id and status=''PENDENTE''';
    Q.ParamByName('id').AsInteger := AID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;


function TVendaRepository.ListarClientesAtivos: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  try
    Result.Connection := FConnection;
    Result.SQL.Text :=
      'select id, nome, cpf_cnpj ' +
      'from cliente ' +
      'where ativo = ''S'' ' +
      'order by nome';
    Result.Open;
  except
    Result.Free;
    raise;
  end;
end;

function TVendaRepository.ObterCliente(AID: Integer): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  try
    Result.Connection := FConnection;
    Result.SQL.Text :=
      'select nome, cpf_cnpj ' +
      'from cliente ' +
      'where id = :id';
    Result.ParamByName('id').AsInteger := AID;
    Result.Open;
  except
    Result.Free;
    raise;
  end;
end;

function TVendaRepository.ListarProdutosAtivos: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  try
    Result.Connection := FConnection;
    Result.SQL.Text :=
      'select id, codigo, descricao, preco ' +
      'from produto ' +
      'where ativo = ''S'' ' +
      'order by descricao';
    Result.Open;
  except
    Result.Free;
    raise;
  end;
end;

function TVendaRepository.ObterProduto(AID: Integer): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  try
    Result.Connection := FConnection;
    Result.SQL.Text :=
      'select id, descricao, preco ' +
      'from produto ' +
      'where id = :id and ativo = ''S''';
    Result.ParamByName('id').AsInteger := AID;
    Result.Open;
  except
    Result.Free;
    raise;
  end;
end;


function TVendaRepository.QuantidadeVendas: Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text := 'select count(*) as QUANTIDADE from venda';
    Q.Open;
    Result := Q.FieldByName('QUANTIDADE').AsInteger;
  finally
    Q.Free;
  end;
end;

end.
