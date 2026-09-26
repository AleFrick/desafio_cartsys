using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Net;
using System.Web.Http;
using Npgsql;
using ERPFinanceiro.Api.Models;

namespace ERPFinanceiro.Api.Controllers
{
    [RoutePrefix("api/financeiro")]
    public class FinanceiroController : ApiController
    {
        private string ConnectionString
        {
            get
            {
                var connection =
                    ConfigurationManager.ConnectionStrings["Catsys"];

                if (connection == null)
                    throw new ConfigurationErrorsException(
                        "A connection string 'Catsys' não foi encontrada no Web.config.");

                return connection.ConnectionString;
            }
        }

        // ============================================================
        // LISTAR
        // ============================================================

        [HttpGet]
        [Route("")]
        public IHttpActionResult Listar()
        {
            var resultado = new List<FinanceiroDto>();

            using (var conn = new NpgsqlConnection(ConnectionString))
            {
                conn.Open();

                const string sql = @"
                    SELECT
                        id,
                        venda_id,
                        valor,
                        status,
                        data_vencimento,
                        data_quitacao,
                        data_cancelamento,
                        motivo_cancelamento
                    FROM financeiro
                    ORDER BY id";

                using (var cmd = new NpgsqlCommand(sql, conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        resultado.Add(Mapear(reader));
                }
            }

            return Ok(resultado);
        }

        // ============================================================
        // BUSCAR POR VENDA
        // ============================================================

        [HttpGet]
        [Route("venda/{vendaId:int}")]
        public IHttpActionResult BuscarPorVenda(int vendaId)
        {
            if (vendaId <= 0)
                return BadRequest("VendaId deve ser maior que zero.");

            using (var conn = new NpgsqlConnection(ConnectionString))
            {
                conn.Open();

                const string sql = @"
                    SELECT
                        id,
                        venda_id,
                        valor,
                        status,
                        data_vencimento,
                        data_quitacao,
                        data_cancelamento,
                        motivo_cancelamento
                    FROM financeiro
                    WHERE venda_id = @vendaId";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@vendaId", vendaId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                            return NotFound();

                        return Ok(Mapear(reader));
                    }
                }
            }
        }

        // ============================================================
        // CRIAR FINANCEIRO
        // ============================================================

        [HttpPost]
        [Route("")]
        public IHttpActionResult Criar(CriarFinanceiroDto dto)
        {
            if (dto == null)
                return BadRequest("Dados financeiros não informados.");

            if (dto.VendaId <= 0)
                return BadRequest("VendaId deve ser maior que zero.");

            if (dto.Valor <= 0)
                return BadRequest("Valor deve ser maior que zero.");

            using (var conn = new NpgsqlConnection(ConnectionString))
            {
                conn.Open();

                // Verifica se a venda existe.
                if (!VendaExiste(conn, dto.VendaId))
                {
                    return Content(
                        HttpStatusCode.NotFound,
                        new
                        {
                            mensagem = "Venda não encontrada.",
                            vendaId = dto.VendaId
                        });
                }

                // Verifica se já existe financeiro para a venda.
                const string verifica = @"
                    SELECT status
                    FROM financeiro
                    WHERE venda_id = @vendaId";

                using (var cmdVerifica = new NpgsqlCommand(
                    verifica,
                    conn))
                {
                    cmdVerifica.Parameters.AddWithValue(
                        "@vendaId",
                        dto.VendaId);

                    var statusExistente =
                        cmdVerifica.ExecuteScalar();

                    if (statusExistente != null &&
                        statusExistente != DBNull.Value)
                    {
                        return Content(
                            HttpStatusCode.Conflict,
                            new
                            {
                                mensagem =
                                    "Já existe um registro financeiro para esta venda.",
                                status =
                                    statusExistente.ToString()
                            });
                    }
                }

                // Cria o financeiro sempre como PENDENTE.
                const string sql = @"
                    INSERT INTO financeiro
                        (
                            venda_id,
                            valor,
                            status,
                            data_vencimento
                        )
                    VALUES
                        (
                            @vendaId,
                            @valor,
                            'PENDENTE',
                            @dataVencimento
                        )
                    RETURNING id";

                using (var cmd = new NpgsqlCommand(
                    sql,
                    conn))
                {
                    cmd.Parameters.AddWithValue(
                        "@vendaId",
                        dto.VendaId);

                    cmd.Parameters.AddWithValue(
                        "@valor",
                        dto.Valor);

                    cmd.Parameters.AddWithValue(
                        "@dataVencimento",
                        (object)dto.DataVencimento ??
                        DBNull.Value);

                    var id =
                        Convert.ToInt32(cmd.ExecuteScalar());

                    return Ok(new
                    {
                        id = id,
                        vendaId = dto.VendaId,
                        status = "PENDENTE",
                        mensagem =
                            "Financeiro criado com sucesso."
                    });
                }
            }
        }

        [HttpGet]
        [Route("relatorio")]
        public IHttpActionResult Relatorio(
            DateTime? dataInicial = null,
            DateTime? dataFinal = null,
            string status = null)
        {
            var resultado = new List<RelatorioFinanceiroDto>();

            using (var conn = new NpgsqlConnection(ConnectionString))
            {
                conn.Open();

                var sql = @"
                    SELECT
                        f.id,
                        f.venda_id,
                        v.data_venda,
                        v.cliente_id,
                        c.nome AS cliente_nome,
                        f.valor,
                        f.status AS status_financeiro,
                        v.status AS status_venda,
                        f.data_vencimento,
                        f.data_quitacao,
                        f.data_cancelamento,
                        f.motivo_cancelamento
                    FROM financeiro f
                    INNER JOIN venda v
                        ON v.id = f.venda_id
                    INNER JOIN cliente c
                        ON c.id = v.cliente_id
                    WHERE 1 = 1
                ";

                if (dataInicial.HasValue)
                    sql += " AND v.data_venda >= @dataInicial";

                if (dataFinal.HasValue)
                    sql += " AND v.data_venda < @dataFinal";

                if (!string.IsNullOrWhiteSpace(status) &&
                    !string.Equals(status, "Todos", StringComparison.OrdinalIgnoreCase))
                {
                    sql += " AND f.status = @status";
                }

                sql += " ORDER BY v.data_venda, f.id";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    if (dataInicial.HasValue)
                    {
                        cmd.Parameters.AddWithValue(
                            "@dataInicial",
                            dataInicial.Value.Date);
                    }

                    if (dataFinal.HasValue)
                    {
                        cmd.Parameters.AddWithValue(
                            "@dataFinal",
                            dataFinal.Value.Date.AddDays(1));
                    }

                    if (!string.IsNullOrWhiteSpace(status) &&
                        !string.Equals(status, "Todos", StringComparison.OrdinalIgnoreCase))
                    {
                        cmd.Parameters.AddWithValue("@status", status);
                    }

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            resultado.Add(new RelatorioFinanceiroDto
                            {
                                Id = Convert.ToInt32(reader["id"]),
                                VendaId = Convert.ToInt32(reader["venda_id"]),
                                DataVenda = Convert.ToDateTime(reader["data_venda"]),
                                ClienteId = Convert.ToInt32(reader["cliente_id"]),
                                ClienteNome = reader["cliente_nome"].ToString(),
                                Valor = Convert.ToDecimal(reader["valor"]),
                                StatusFinanceiro = reader["status_financeiro"].ToString(),
                                StatusVenda = reader["status_venda"].ToString(),

                                DataVencimento =
                                    reader["data_vencimento"] == DBNull.Value
                                        ? (DateTime?)null
                                        : Convert.ToDateTime(reader["data_vencimento"]),

                                DataQuitacao =
                                    reader["data_quitacao"] == DBNull.Value
                                        ? (DateTime?)null
                                        : Convert.ToDateTime(reader["data_quitacao"]),

                                DataCancelamento =
                                    reader["data_cancelamento"] == DBNull.Value
                                        ? (DateTime?)null
                                        : Convert.ToDateTime(reader["data_cancelamento"]),

                                MotivoCancelamento =
                                    reader["motivo_cancelamento"] == DBNull.Value
                                        ? null
                                        : reader["motivo_cancelamento"].ToString()
                            });
                        }
                    }
                }
            }

            return Ok(resultado);
        }

        // ============================================================
        // QUITAR VENDA
        //
        // Atualiza:
        //   FINANCEIRO -> QUITADA
        //   VENDA      -> QUITADA
        //
        // As duas operações fazem parte da mesma transação.
        // ============================================================

        [HttpPost]
        [Route("venda/{vendaId:int}/quitar")]
        public IHttpActionResult Quitar(int vendaId)
        {
            if (vendaId <= 0)
                return BadRequest(
                    "VendaId deve ser maior que zero.");

            using (var conn = new NpgsqlConnection(
                ConnectionString))
            {
                conn.Open();

                using (var transaction = conn.BeginTransaction())
                {
                    try
                    {
                        // ------------------------------------------------
                        // 1. Verifica o financeiro
                        // ------------------------------------------------

                        string statusFinanceiro = null;

                        const string sqlStatusFinanceiro = @"
                            SELECT status
                            FROM financeiro
                            WHERE venda_id = @vendaId
                            FOR UPDATE";

                        using (var cmd = new NpgsqlCommand(
                            sqlStatusFinanceiro,
                            conn,
                            transaction))
                        {
                            cmd.Parameters.AddWithValue(
                                "@vendaId",
                                vendaId);

                            var result =
                                cmd.ExecuteScalar();

                            if (result == null ||
                                result == DBNull.Value)
                            {
                                transaction.Rollback();
                                return NotFound();
                            }

                            statusFinanceiro =
                                result.ToString();
                        }

                        // ------------------------------------------------
                        // 2. Valida status
                        // ------------------------------------------------

                        if (statusFinanceiro == "QUITADA")
                        {
                            transaction.Rollback();

                            return Content(
                                HttpStatusCode.Conflict,
                                new
                                {
                                    mensagem =
                                        "A venda já está quitada."
                                });
                        }

                        if (statusFinanceiro == "CANCELADA")
                        {
                            transaction.Rollback();

                            return Content(
                                HttpStatusCode.Conflict,
                                new
                                {
                                    mensagem =
                                        "Não é possível quitar uma venda cancelada."
                                });
                        }

                        // ------------------------------------------------
                        // 3. Atualiza FINANCEIRO
                        // ------------------------------------------------

                        const string sqlFinanceiro = @"
                            UPDATE financeiro
                            SET
                                status = 'QUITADA',
                                data_quitacao =
                                    CURRENT_TIMESTAMP,
                                data_atualizacao =
                                    CURRENT_TIMESTAMP
                            WHERE venda_id = @vendaId
                              AND status = 'PENDENTE'";

                        int financeiroAtualizado;

                        using (var cmd = new NpgsqlCommand(
                            sqlFinanceiro,
                            conn,
                            transaction))
                        {
                            cmd.Parameters.AddWithValue(
                                "@vendaId",
                                vendaId);

                            financeiroAtualizado =
                                cmd.ExecuteNonQuery();
                        }

                        if (financeiroAtualizado != 1)
                        {
                            transaction.Rollback();

                            return Content(
                                HttpStatusCode.Conflict,
                                new
                                {
                                    mensagem =
                                        "O financeiro não está pendente."
                                });
                        }

                        // ------------------------------------------------
                        // 4. Atualiza VENDA
                        // ------------------------------------------------

                        const string sqlVenda = @"
                            UPDATE venda
                            SET
                                status = 'QUITADA',
                                data_atualizacao =
                                    CURRENT_TIMESTAMP
                            WHERE id = @vendaId
                              AND status = 'PENDENTE'";

                        int vendaAtualizada;

                        using (var cmd = new NpgsqlCommand(
                            sqlVenda,
                            conn,
                            transaction))
                        {
                            cmd.Parameters.AddWithValue(
                                "@vendaId",
                                vendaId);

                            vendaAtualizada =
                                cmd.ExecuteNonQuery();
                        }

                        if (vendaAtualizada != 1)
                        {
                            transaction.Rollback();

                            return Content(
                                HttpStatusCode.Conflict,
                                new
                                {
                                    mensagem =
                                        "A venda não está pendente ou não foi encontrada."
                                });
                        }

                        // ------------------------------------------------
                        // 5. Confirma as duas alterações
                        // ------------------------------------------------

                        transaction.Commit();

                        return Ok(new
                        {
                            vendaId = vendaId,
                            status = "QUITADA",
                            mensagem =
                                "Venda e financeiro quitados com sucesso."
                        });
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        // ============================================================
        // CANCELAR VENDA
        //
        // Atualiza:
        //   FINANCEIRO -> CANCELADA
        //   VENDA      -> CANCELADA
        //
        // As duas operações fazem parte da mesma transação.
        // ============================================================

        [HttpPost]
        [Route("venda/{vendaId:int}/cancelar")]
        public IHttpActionResult Cancelar(
            int vendaId,
            MotivoCancelamentoDto dto)
        {
            if (vendaId <= 0)
                return BadRequest(
                    "VendaId deve ser maior que zero.");

            if (dto == null ||
                string.IsNullOrWhiteSpace(dto.Motivo))
            {
                return BadRequest(
                    "Informe o motivo do cancelamento.");
            }

            var motivo = dto.Motivo.Trim();

            if (motivo.Length > 500)
            {
                return BadRequest(
                    "O motivo do cancelamento deve ter no máximo 500 caracteres.");
            }

            using (var conn = new NpgsqlConnection(
                ConnectionString))
            {
                conn.Open();

                using (var transaction = conn.BeginTransaction())
                {
                    try
                    {
                        // ------------------------------------------------
                        // 1. Verifica o financeiro
                        // ------------------------------------------------

                        string statusFinanceiro = null;

                        const string sqlStatusFinanceiro = @"
                            SELECT status
                            FROM financeiro
                            WHERE venda_id = @vendaId
                            FOR UPDATE";

                        using (var cmd = new NpgsqlCommand(
                            sqlStatusFinanceiro,
                            conn,
                            transaction))
                        {
                            cmd.Parameters.AddWithValue(
                                "@vendaId",
                                vendaId);

                            var result =
                                cmd.ExecuteScalar();

                            if (result == null ||
                                result == DBNull.Value)
                            {
                                transaction.Rollback();
                                return NotFound();
                            }

                            statusFinanceiro =
                                result.ToString();
                        }

                        // ------------------------------------------------
                        // 2. Valida status
                        // ------------------------------------------------

                        if (statusFinanceiro == "CANCELADA")
                        {
                            transaction.Rollback();

                            return Content(
                                HttpStatusCode.Conflict,
                                new
                                {
                                    mensagem =
                                        "A venda já está cancelada."
                                });
                        }

                        if (statusFinanceiro == "QUITADA")
                        {
                            transaction.Rollback();

                            return Content(
                                HttpStatusCode.Conflict,
                                new
                                {
                                    mensagem =
                                        "Não é possível cancelar uma venda já quitada."
                                });
                        }

                        // ------------------------------------------------
                        // 3. Atualiza FINANCEIRO
                        // ------------------------------------------------

                        const string sqlFinanceiro = @"
                            UPDATE financeiro
                            SET
                                status = 'CANCELADA',
                                data_cancelamento =
                                    CURRENT_TIMESTAMP,
                                motivo_cancelamento =
                                    @motivo,
                                data_atualizacao =
                                    CURRENT_TIMESTAMP
                            WHERE venda_id = @vendaId
                              AND status = 'PENDENTE'";

                        int financeiroAtualizado;

                        using (var cmd = new NpgsqlCommand(
                            sqlFinanceiro,
                            conn,
                            transaction))
                        {
                            cmd.Parameters.AddWithValue(
                                "@vendaId",
                                vendaId);

                            cmd.Parameters.AddWithValue(
                                "@motivo",
                                motivo);

                            financeiroAtualizado =
                                cmd.ExecuteNonQuery();
                        }

                        if (financeiroAtualizado != 1)
                        {
                            transaction.Rollback();

                            return Content(
                                HttpStatusCode.Conflict,
                                new
                                {
                                    mensagem =
                                        "O financeiro não está pendente."
                                });
                        }

                        // ------------------------------------------------
                        // 4. Atualiza VENDA
                        // ------------------------------------------------

                        const string sqlVenda = @"
                            UPDATE venda
                            SET
                                status = 'CANCELADA',
                                data_atualizacao =
                                    CURRENT_TIMESTAMP
                            WHERE id = @vendaId
                              AND status = 'PENDENTE'";

                        int vendaAtualizada;

                        using (var cmd = new NpgsqlCommand(
                            sqlVenda,
                            conn,
                            transaction))
                        {
                            cmd.Parameters.AddWithValue(
                                "@vendaId",
                                vendaId);

                            vendaAtualizada =
                                cmd.ExecuteNonQuery();
                        }

                        if (vendaAtualizada != 1)
                        {
                            transaction.Rollback();

                            return Content(
                                HttpStatusCode.Conflict,
                                new
                                {
                                    mensagem =
                                        "A venda não está pendente ou não foi encontrada."
                                });
                        }

                        // ------------------------------------------------
                        // 5. Confirma as duas alterações
                        // ------------------------------------------------

                        transaction.Commit();

                        return Ok(new
                        {
                            vendaId = vendaId,
                            status = "CANCELADA",
                            motivo = motivo,
                            mensagem =
                                "Venda e financeiro cancelados com sucesso."
                        });
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        // ============================================================
        // VERIFICA SE VENDA EXISTE
        // ============================================================

        private static bool VendaExiste(
            NpgsqlConnection conn,
            int vendaId)
        {
            const string sql = @"
                SELECT COUNT(1)
                FROM venda
                WHERE id = @vendaId";

            using (var cmd = new NpgsqlCommand(
                sql,
                conn))
            {
                cmd.Parameters.AddWithValue(
                    "@vendaId",
                    vendaId);

                return Convert.ToInt32(
                    cmd.ExecuteScalar()) > 0;
            }
        }

        // ============================================================
        // MAPEIA STATUS DO FINANCEIRO
        // ============================================================

        private static string ObterStatus(
            NpgsqlConnection conn,
            int vendaId)
        {
            const string sql = @"
                SELECT status
                FROM financeiro
                WHERE venda_id = @vendaId";

            using (var cmd = new NpgsqlCommand(
                sql,
                conn))
            {
                cmd.Parameters.AddWithValue(
                    "@vendaId",
                    vendaId);

                var result =
                    cmd.ExecuteScalar();

                if (result == null ||
                    result == DBNull.Value)
                {
                    return null;
                }

                return result.ToString();
            }
        }

        // ============================================================
        // MAPEAR FINANCEIRO
        // ============================================================

        private static FinanceiroDto Mapear(
            IDataRecord reader)
        {
            return new FinanceiroDto
            {
                Id =
                    Convert.ToInt32(
                        reader["id"]),

                VendaId =
                    Convert.ToInt32(
                        reader["venda_id"]),

                Valor =
                    Convert.ToDecimal(
                        reader["valor"]),

                Status =
                    reader["status"].ToString(),

                DataVencimento =
                    reader["data_vencimento"] ==
                    DBNull.Value
                        ? (DateTime?)null
                        : Convert.ToDateTime(
                            reader["data_vencimento"]),

                DataQuitacao =
                    reader["data_quitacao"] ==
                    DBNull.Value
                        ? (DateTime?)null
                        : Convert.ToDateTime(
                            reader["data_quitacao"]),

                DataCancelamento =
                    reader["data_cancelamento"] ==
                    DBNull.Value
                        ? (DateTime?)null
                        : Convert.ToDateTime(
                            reader["data_cancelamento"]),

                MotivoCancelamento =
                    reader["motivo_cancelamento"] ==
                    DBNull.Value
                        ? null
                        : reader["motivo_cancelamento"]
                            .ToString()
            };
        }
    }
}