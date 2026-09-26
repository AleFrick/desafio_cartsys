# ERP Financeiro API - versão 3

## Objetivo desta versão

Esta versão corrige os problemas de referências da versão anterior:

- `System.Data` agora está referenciado explicitamente.
- ASP.NET Web API é instalado por `PackageReference`.
- Npgsql é instalado por `PackageReference`.
- Não existem `HintPath` apontando para uma pasta `packages` que ainda não foi restaurada.
- O projeto continua explicitamente em .NET Framework 4.8.
- Não usa `ProjectTypeGuids` de ASP.NET Web Application.
- Não usa Entity Framework.
- Não adiciona referências manuais a `System.Memory`, `System.Buffers` ou `System.Runtime.CompilerServices.Unsafe`.

## Primeiro passo após abrir

No Visual Studio:

1. Abra `ERPFinanceiro.sln`.
2. Aguarde a restauração automática dos pacotes NuGet.
3. Se aparecer uma barra informando que os pacotes precisam ser restaurados, clique em Restaurar.
4. Depois execute `Compilar > Recompilar Solução`.

Se a restauração não ocorrer automaticamente:

`Ferramentas > Gerenciador de Pacotes NuGet > Configurações do Gerenciador de Pacotes`

e confirme que `nuget.org` está habilitado.

Também é possível clicar com o botão direito na solução e procurar por:

`Restaurar Pacotes NuGet`

## Banco

O Web.config já contém:

Host=localhost;Port=5432;Database=catsys;Username=postgres;Password=postgres;

## Endpoint inicial

Depois de iniciar pelo IIS Express:

`http://localhost:5000/api/financeiro`

## Dependência Npgsql

Npgsql 3.2.7 é antigo e o NuGet sinaliza uma vulnerabilidade conhecida. Ele foi escolhido nesta versão especificamente para evitar a cadeia de incompatibilidades de assemblies que ocorreu com Npgsql 4.x no ambiente .NET Framework.

Para produção, a versão deve ser revisada/atualizada.


## Observação sobre o schema FINANCEIRO

O projeto utiliza exatamente os nomes do schema atual do desafio:

- `DATA_VENCIMENTO`
- `DATA_QUITACAO`
- `DATA_CANCELAMENTO`
- `MOTIVO_CANCELAMENTO`

Os status utilizados são:

- `PENDENTE`
- `QUITADA`
- `CANCELADA`

Ao quitar, a API grava `DATA_QUITACAO` e `DATA_ATUALIZACAO`.
Ao cancelar, grava `DATA_CANCELAMENTO`, `MOTIVO_CANCELAMENTO` e `DATA_ATUALIZACAO`.


## Melhorias da API - v5

Além das operações básicas, esta versão valida regras antes de alterar o banco:

- criação valida se a venda existe;
- criação impede duplicidade de financeiro para a mesma venda;
- `VendaId` inválido retorna 400;
- quitação de financeiro inexistente retorna 404;
- quitação de financeiro já quitado retorna 409;
- quitação de financeiro cancelado retorna 409;
- cancelamento de financeiro inexistente retorna 404;
- cancelamento de financeiro já cancelado retorna 409;
- cancelamento de financeiro quitado retorna 409;
- motivo de cancelamento é obrigatório;
- motivo de cancelamento é limitado a 500 caracteres;
- as operações usam os status do schema: `PENDENTE`, `QUITADA`, `CANCELADA`;
- a API não expõe diretamente exceções de FK para situações esperadas de negócio;
- a criação retorna um JSON simples em vez de uma URL de recurso inexistente.
