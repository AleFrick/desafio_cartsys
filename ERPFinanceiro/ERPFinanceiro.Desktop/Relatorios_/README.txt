RELATÓRIO FINANCEIRO - C# / FASTREPORT

Arquivos incluídos:
- API/Models/RelatorioFinanceiroDto.cs
- Desktop/Models/RelatorioFinanceiroDto.cs
- Desktop/Services/RelatorioService.cs

Integração:
GET http://localhost:5000/api/financeiro/relatorio

Parâmetros opcionais:
dataInicial=yyyy-MM-dd
dataFinal=yyyy-MM-dd
status=PENDENTE|QUITADA|CANCELADA

Observação:
O arquivo .frx depende da versão do FastReport instalada no projeto.
Depois de adicionar os arquivos ao projeto, o relatório deve ser criado no designer do FastReport com a fonte de dados "Financeiro".
