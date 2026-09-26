# ERP Financeiro Desktop

Projeto WinForms .NET Framework 4.8 para a tela do ERP Financeiro.

Esta versão não depende de Newtonsoft.Json/NuGet para abrir o projeto. A serialização JSON usa `System.Web.Extensions` (JavaScriptSerializer), já disponível no .NET Framework.

## API
Por padrão a tela chama:
http://localhost:5000/

Se necessário, altere no construtor de `FrmFinanceiro`.

## Funcionalidades
- Consulta de financeiros
- Filtro por venda, status e vencimento
- Atualizar e limpar filtros
- Quitar financeiro
- Cancelar financeiro com motivo
- Validação de estados
- Tratamento de erros da API
- Total dos registros filtrados
- Detalhes por duplo clique

## Observação
O desafio pede DevExpress. A lógica está pronta e isolada para que os controles visuais possam ser trocados pelos controles DevExpress da versão instalada no ambiente.
