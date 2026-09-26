# catsys — Guia de Execução e Entrega

## 1. Visão geral

O projeto é composto por dois sistemas que trabalham de forma integrada:

- **ERP Vendas** — aplicação desktop desenvolvida em Delphi.
- **ERP Financeiro** — composto por uma API REST em C# e uma aplicação desktop para consulta e operação financeira.

A comunicação entre o ERP Vendas e o ERP Financeiro é realizada por HTTP/REST.

---

## 2. Estrutura dos projetos

### ERP Vendas — Delphi

Principais camadas:

```text
ERPVendas
├── Data
├── Model
├── Repository
├── Service
├── Controller
└── View
```

Responsabilidades principais:

- cadastro de clientes;
- cadastro de produtos;
- criação de vendas;
- cálculo do total da venda;
- persistência da venda;
- criação do registro financeiro através da API;
- visualização do relatório da venda.

A aplicação utiliza FireDAC para acesso ao PostgreSQL.

### ERP Financeiro — C#

O projeto possui duas partes:

```text
ERPFinanceiro
├── ERPFinanceiro.Api
└── ERPFinanceiro.Desktop
```

#### ERPFinanceiro.Api

API REST responsável pelas operações financeiras.

Principais operações:

- listar registros financeiros;
- quitar uma venda;
- cancelar uma venda.

#### ERPFinanceiro.Desktop

Aplicação desktop responsável pela consulta e operação dos registros financeiros.

A comunicação com a API fica concentrada no serviço:

```text
Services/FinanceiroApiService.cs
```

---

## 3. Tecnologias utilizadas

### ERP Vendas

- Delphi
- VCL
- FireDAC
- PostgreSQL
- ReportBuilder
- Arquitetura em camadas

### ERP Financeiro

- C#
- .NET Framework 4.8
- ASP.NET Web API
- PostgreSQL
- Npgsql
- FastReport
- HTTP/REST

---

## 4. Banco de dados

O banco utilizado nos testes é:

```text
Servidor: localhost
Porta: 5432
Banco: catsys
Usuário: postgres
Senha: postgres
```

A estrutura possui, entre outras, as tabelas:

```text
CLIENTE
PRODUTO
VENDA
VENDA_ITEM
FINANCEIRO
```

Também existe a view:

```text
VW_VENDAS_FINANCEIRO
```

utilizada para consulta conjunta das informações de venda e financeiro.

### Configuração do Delphi

O ERP Vendas utiliza o arquivo:

```text
config.ini
```

Exemplo:

```ini
[DATABASE]
Server=localhost
Port=5432
Database=catsys
Username=postgres
Password=postgres
```

Caso o ambiente de execução seja diferente, os dados devem ser ajustados conforme a instalação do PostgreSQL.

### Configuração da API

A API utiliza a connection string configurada no `Web.config`.

O ambiente utilizado no desenvolvimento aponta para:

```text
Host=localhost
Port=5432
Database=catsys
Username=postgres
Password=postgres
```

---

## 5. Ordem para executar os sistemas

A ordem recomendada é:

```text
1. PostgreSQL
      ↓
2. ERPFinanceiro.Api
      ↓
3. ERP Vendas Delphi
      ↓
4. ERPFinanceiro.Desktop
```

O ERP Vendas depende da API financeira para criar o registro financeiro depois que uma venda é gravada.

---

## 6. Executando a API

A API pode ser executada utilizando IIS Express.

A configuração utilizada durante os testes foi:

```text
http://localhost:5000
```

Exemplo:

```powershell
& "C:\Program Files\IIS Express\iisexpress.exe" /path:"CAMINHO\ERPFinanceiro.Api" /port:5000
```

A janela/processo da API deve permanecer em execução enquanto o ERP Vendas estiver sendo utilizado.

---

## 7. Executando o ERP Vendas

Abra:

```text
ERPVendas.dproj
```

no Delphi.

Confirme a plataforma configurada para o ambiente de execução e execute o projeto.

Antes de criar uma venda, certifique-se de que:

- o PostgreSQL está ativo;
- o banco `catsys` está disponível;
- a API financeira está executando em `localhost:5000`.

---

## 8. Fluxo de criação da venda

Quando uma venda é gravada, o fluxo principal é:

```text
Tela de Vendas
      ↓
TVendaController
      ↓
TVendaService
      ↓
TVendaRepository
      ↓
PostgreSQL
      ↓
TFinanceiroApiService
      ↓
HTTP POST
      ↓
ERPFinanceiro.Api
      ↓
FINANCEIRO
```

A venda é persistida primeiro no banco local e, depois, o ERP Vendas solicita à API a criação do registro financeiro correspondente.

A comunicação financeira foi isolada por uma interface:

```text
IFinanceiroService
```

e implementada por:

```text
TFinanceiroApiService
```

Isso mantém o serviço de venda desacoplado da implementação concreta da comunicação HTTP.

---

## 9. Endpoints financeiros

A API disponibiliza as operações utilizadas pelo Desktop.

### Listagem

```http
GET /api/financeiro
```

### Quitação

```http
POST /api/financeiro/venda/{vendaId}/quitar
```

### Cancelamento

```http
POST /api/financeiro/venda/{vendaId}/cancelar
```

O cancelamento recebe o motivo no corpo da requisição.

---

## 10. Quitação

Ao quitar uma venda pelo ERP Financeiro, a operação atualiza:

```text
VENDA.STATUS       → QUITADA
FINANCEIRO.STATUS  → QUITADA
```

A data de quitação também é registrada no financeiro.

A operação é realizada pela API de forma transacional, mantendo os dois registros sincronizados.

---

## 11. Cancelamento

Ao cancelar uma venda pelo ERP Financeiro:

```text
VENDA.STATUS       → CANCELADA
FINANCEIRO.STATUS  → CANCELADA
```

No financeiro também são registrados:

- data do cancelamento;
- motivo do cancelamento.

---

## 12. Relatórios

### Relatório de venda

O ERP Vendas possui relatório desenvolvido com ReportBuilder.

O relatório apresenta os dados da venda, cliente, itens, valores e total.

### Relatório financeiro

O ERP Financeiro Desktop utiliza FastReport para geração do relatório financeiro.

O arquivo do relatório fica em:

```text
ERPFinanceiro.Desktop/Relatorios/RelatorioFinanceiro.frx
```

---

## 13. Arquitetura e POO

O ERP Vendas foi organizado em camadas para separar responsabilidades:

```text
View
 ↓
Controller
 ↓
Service
 ↓
Repository
 ↓
Data Access
```

### Model

Representa as entidades de negócio.

Exemplos:

```text
Cliente
Produto
Venda
VendaItem
```

### Repository

Responsável pela persistência e consultas relacionadas às entidades.

### Service

Concentra regras de negócio e coordena operações entre componentes.

### Controller

Faz a ponte entre a camada de apresentação e os serviços.

### Interface

A comunicação financeira utiliza:

```text
IFinanceiroService
```

permitindo que o `TVendaService` dependa de uma abstração em vez de uma implementação concreta.

---

## 14. Princípios SOLID aplicados

### Single Responsibility Principle

As responsabilidades principais estão separadas entre:

- View;
- Controller;
- Service;
- Repository;
- comunicação com API.

### Dependency Inversion Principle

O serviço de venda recebe:

```text
IFinanceiroService
```

em vez de depender diretamente de:

```text
TFinanceiroApiService
```

Isso reduz o acoplamento entre a regra de venda e a implementação da integração financeira.

### Separation of Concerns

A comunicação HTTP não fica diretamente dentro das telas. Ela está concentrada no serviço de API.

No Desktop C#, a comunicação REST também está isolada em:

```text
FinanceiroApiService
```

---

## 15. Tratamento de erros

O ERP Vendas trata falhas na comunicação com a API e informa ao usuário quando a venda foi gravada, mas o financeiro não pôde ser criado.

Exemplo de cenário:

```text
VENDA gravada
     ↓
API indisponível
     ↓
FINANCEIRO não criado
```

Nesse caso, a aplicação não oculta a falha de integração e apresenta a informação ao usuário.

---

## 16. Testes realizados

Durante a validação foram testados:

- cadastro de cliente;
- alteração de cliente;
- cadastro de produto;
- alteração de produto;
- criação de venda;
- cálculo do total;
- criação do financeiro via API;
- reabertura da venda;
- relatório da venda;
- quitação;
- cancelamento;
- sincronização dos status entre `VENDA` e `FINANCEIRO`.

Os testes funcionais realizados foram concluídos com sucesso.

---

## 17. Observações para avaliação

Para testar o fluxo completo:

1. Inicie o PostgreSQL.
2. Inicie a `ERPFinanceiro.Api` na porta `5000`.
3. Execute o `ERPVendas`.
4. Cadastre cliente e produto.
5. Crie uma venda.
6. Verifique a criação do financeiro.
7. Execute o `ERPFinanceiro.Desktop`.
8. Consulte o financeiro.
9. Teste a quitação ou o cancelamento.
10. Confira a sincronização dos status.
11. Gere os relatórios.

---

## 18. Estrutura de entrega

O projeto Delphi deve ser aberto pelo:

```text
ERPVendas.dproj
```

O projeto C# possui a solução:

```text
ERPFinanceiro.sln
```

A entrega foi limpa de artefatos de compilação e arquivos temporários para facilitar a avaliação e versionamento.

---

## 19. Observação sobre configuração

Os arquivos de configuração presentes no projeto utilizam os dados do ambiente utilizado durante o desenvolvimento.

Em um ambiente real, recomenda-se não versionar senhas de banco diretamente e utilizar configuração segura por ambiente.

---

## 20. Resumo do fluxo completo

```text
                ┌──────────────────────┐
                │    ERP Vendas        │
                │       Delphi         │
                └──────────┬───────────┘
                           │
                           │ HTTP
                           ▼
                ┌──────────────────────┐
                │  ERP Financeiro API  │
                │        C#            │
                └──────────┬───────────┘
                           │
                           ▼
                ┌──────────────────────┐
                │      PostgreSQL      │
                │       catsys         │
                └──────────┬───────────┘
                           ▲
                           │
                ┌──────────┴───────────┐
                │ ERP Financeiro       │
                │      Desktop         │
                └──────────────────────┘
```

O ERP Vendas é responsável pelo processo comercial e solicita à API a criação do financeiro. O ERP Financeiro é responsável pelas operações de quitação e cancelamento, mantendo os estados de `VENDA` e `FINANCEIRO` sincronizados.
