-- Migração do Financeiro - PASSO 4: conferência. Rode depois do passo 3 (a tabela de staging ainda precisa existir).
-- "esperado" = o que o CSV trazia; "migrado" = o que está em financeiro_lancamento e veio da migração (cd_legado preenchido).
-- Toda linha deve ter diferença 0. Compare os saldos finais com a planilha original.

CREATE OR REPLACE FUNCTION pg_temp.numero(t TEXT) RETURNS NUMERIC AS $$
    SELECT CASE
        WHEN btrim(COALESCE(t, '')) = '' THEN NULL
        WHEN regexp_replace(t, '[^0-9.,-]', '', 'g') !~ '\d' THEN NULL
        WHEN t ~ ',' AND t ~ '\.' AND position(',' IN t) > position('.' IN t)
            THEN replace(replace(regexp_replace(t, '[^0-9.,-]', '', 'g'), '.', ''), ',', '.')::NUMERIC
        WHEN t ~ ',' THEN replace(regexp_replace(t, '[^0-9.,-]', '', 'g'), ',', '.')::NUMERIC
        ELSE regexp_replace(t, '[^0-9.-]', '', 'g')::NUMERIC
    END
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION pg_temp.mes(t TEXT) RETURNS DATE AS $$
    SELECT CASE
        WHEN btrim(COALESCE(t, '')) ~ '^\d{4}-(0[1-9]|1[0-2])' THEN (LEFT(btrim(t), 7) || '-01')::DATE
        WHEN btrim(COALESCE(t, '')) ~ '^(0[1-9]|1[0-2])/\d{4}$' THEN to_date('01/' || btrim(t), 'DD/MM/YYYY')
    END
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE TEMP VIEW v_fin_csv AS
SELECT ordem + 1 AS linha_planilha, pg_temp.mes(mes) AS dt_mes,
       CASE WHEN lower(btrim(tipo)) IN ('entrada', 'e') THEN 'ENTRADA' WHEN lower(btrim(tipo)) IN ('saida', 'saída', 's') THEN 'SAIDA' END AS cd_tipo,
       lower(btrim(categoria)) AS categoria, pg_temp.numero(valor) AS valor, pg_temp.numero(saldo_final) AS saldo_final
FROM stg_financeiro_lancamento
WHERE COALESCE(btrim(mes), '') <> '' OR COALESCE(btrim(tipo), '') <> '' OR COALESCE(btrim(categoria), '') <> '' OR COALESCE(btrim(valor), '') <> '';

-- 1) Totais gerais
SELECT 'lancamentos' AS item, (SELECT COUNT(*) FROM v_fin_csv WHERE categoria IS DISTINCT FROM 'saldo anterior')::NUMERIC AS esperado,
       (SELECT COUNT(*) FROM financeiro_lancamento WHERE cd_legado IS NOT NULL)::NUMERIC AS migrado
UNION ALL
SELECT 'entradas', (SELECT COALESCE(SUM(round(valor, 2)), 0) FROM v_fin_csv WHERE cd_tipo = 'ENTRADA' AND categoria IS DISTINCT FROM 'saldo anterior'),
       (SELECT COALESCE(SUM(l.vl_lancamento), 0) FROM financeiro_lancamento l JOIN financeiro_categoria c ON c.id_categoria = l.id_categoria
        WHERE l.cd_legado IS NOT NULL AND c.cd_tipo = 'ENTRADA')
UNION ALL
SELECT 'saidas', (SELECT COALESCE(SUM(round(valor, 2)), 0) FROM v_fin_csv WHERE cd_tipo = 'SAIDA'),
       (SELECT COALESCE(SUM(l.vl_lancamento), 0) FROM financeiro_lancamento l JOIN financeiro_categoria c ON c.id_categoria = l.id_categoria
        WHERE l.cd_legado IS NOT NULL AND c.cd_tipo = 'SAIDA');

-- 2) Mês a mês: entradas, saídas e saldo final (planilha x NordTool). Diferença deve ser 0 em todos.
WITH csv AS (
    SELECT dt_mes,
           COALESCE(SUM(round(valor, 2)) FILTER (WHERE cd_tipo = 'ENTRADA' AND categoria IS DISTINCT FROM 'saldo anterior'), 0) AS entradas,
           COALESCE(SUM(round(valor, 2)) FILTER (WHERE cd_tipo = 'SAIDA'), 0) AS saidas,
           MAX(saldo_final) AS saldo_final
    FROM v_fin_csv GROUP BY dt_mes
), db AS (
    SELECT l.dt_competencia AS dt_mes,
           COALESCE(SUM(l.vl_lancamento) FILTER (WHERE c.cd_tipo = 'ENTRADA'), 0) AS entradas,
           COALESCE(SUM(l.vl_lancamento) FILTER (WHERE c.cd_tipo = 'SAIDA'), 0) AS saidas
    FROM financeiro_lancamento l JOIN financeiro_categoria c ON c.id_categoria = l.id_categoria
    WHERE l.cd_legado IS NOT NULL GROUP BY l.dt_competencia
)
SELECT to_char(csv.dt_mes, 'YYYY-MM') AS mes, csv.entradas AS entradas_csv, COALESCE(db.entradas, 0) AS entradas_banco,
       csv.entradas - COALESCE(db.entradas, 0) AS dif_entradas, csv.saidas AS saidas_csv, COALESCE(db.saidas, 0) AS saidas_banco,
       csv.saidas - COALESCE(db.saidas, 0) AS dif_saidas, csv.saldo_final AS saldo_final_planilha, m.vl_saldo_final AS saldo_final_banco,
       csv.saldo_final - m.vl_saldo_final AS dif_saldo, COALESCE(m.in_fechado, FALSE) AS fechado
FROM csv LEFT JOIN db ON db.dt_mes = csv.dt_mes LEFT JOIN financeiro_mes m ON m.dt_competencia = csv.dt_mes
ORDER BY csv.dt_mes;

-- 3) Por pessoa (migrado): confira se o dono dos lançamentos está certo
SELECT p.nm_pessoa, COUNT(*) AS lancamentos, SUM(l.vl_lancamento) AS total
FROM financeiro_lancamento l JOIN financeiro_pessoa p ON p.id_pessoa = l.id_pessoa
WHERE l.cd_legado IS NOT NULL GROUP BY p.nm_pessoa ORDER BY p.nm_pessoa;
