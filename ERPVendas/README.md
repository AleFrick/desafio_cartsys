# CARTSYS - ERP de Vendas - Delphi 12

Esta entrega contém uma base funcional do ERP de Vendas com as telas chamadas pelo menu principal.

## Telas
- Principal
- Clientes
- Produtos
- Vendas

## Arquitetura
Model / Repository / Service / Controller / View.

## PostgreSQL
- Server: localhost
- Port: 5432
- Database: catsys
- User: postgres
- Password: postgres

Execute `Database/01_catsys_postgresql.sql` no banco `catsys`.

## libpq.dll
O FireDAC PostgreSQL precisa da `libpq.dll` compatível com a arquitetura do executável. Se o projeto estiver em Win32, use a DLL 32-bit. Coloque a DLL no PATH ou ao lado do EXE.

## Importante
Não foi ativado `Connected=True` no DFM. A conexão é aberta no FormCreate da tela principal para que uma falha seja apresentada de forma controlada.

A especificação do desafio discutida anteriormente mencionava Firebird 3.0, enquanto esta versão usa PostgreSQL porque o banco atual foi criado no pgAdmin. Se o avaliador exigir Firebird, a camada de persistência deve ser convertida antes da entrega.

## Correções da compilação
- Repositórios agora possuem Atualizar, compatível com os Services.
- Units FireDAC.Stan.Param adicionadas para os parâmetros.
- Arquivos Delphi normalizados para CRLF.
