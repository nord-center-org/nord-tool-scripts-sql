-- Migração do casamento - PASSO 4: conferência. Rode depois do passo 3 (as tabelas de staging ainda precisam existir).
-- "esperado" = o que o CSV trazia (staging); "migrado" = o que está nas tabelas definitivas e veio da migração
-- (cd_legado preenchido). Toda linha deve ter diferença 0. Compare também com a tela/planilha do Lugia.

-- Valor com ponto decimal; aceita "R$ 1.234,56" (vírgula decimal) quando não há ponto de decimal evidente.
CREATE OR REPLACE FUNCTION pg_temp.numero(t TEXT) RETURNS NUMERIC AS $$
    SELECT CASE
        WHEN btrim(COALESCE(t, '')) = '' THEN 0
        WHEN t ~ ',' AND t ~ '\.' AND position(',' IN t) > position('.' IN t)
            THEN replace(replace(regexp_replace(t, '[^0-9.,-]', '', 'g'), '.', ''), ',', '.')::NUMERIC
        WHEN t ~ ',' THEN replace(regexp_replace(t, '[^0-9.,-]', '', 'g'), ',', '.')::NUMERIC
        ELSE regexp_replace(t, '[^0-9.-]', '', 'g')::NUMERIC
    END
$$ LANGUAGE SQL IMMUTABLE;

-- 1) Fornecedores por status
WITH s AS (
    SELECT CASE lower(btrim(COALESCE(status, '')))
               WHEN 'contratado' THEN 'CONTRATADO'
               WHEN 'orçamento' THEN 'ORCAMENTO' WHEN 'orcamento' THEN 'ORCAMENTO'
               ELSE 'PESQUISANDO' END AS chave, COUNT(*) AS qt
    FROM stg_casamento_fornecedor GROUP BY 1
), m AS (
    SELECT nm_status AS chave, COUNT(*) AS qt FROM casamento_fornecedor WHERE cd_legado IS NOT NULL GROUP BY 1
)
SELECT 'fornecedores/' || COALESCE(s.chave, m.chave) AS item, COALESCE(s.qt, 0) AS esperado, COALESCE(m.qt, 0) AS migrado,
       COALESCE(m.qt, 0) - COALESCE(s.qt, 0) AS diferenca
FROM s FULL JOIN m ON m.chave = s.chave ORDER BY 1;

-- 2) Soma dos valores contratados (mesma conversão do passo 3)
SELECT 'valor contratado' AS item,
       (SELECT COALESCE(SUM(pg_temp.numero(value)), 0)
          FROM stg_casamento_fornecedor WHERE lower(btrim(COALESCE(status, ''))) = 'contratado') AS esperado,
       (SELECT COALESCE(SUM(vl_valor), 0) FROM casamento_fornecedor WHERE cd_legado IS NOT NULL AND nm_status = 'CONTRATADO') AS migrado;

-- 3) Convidados por status
WITH s AS (
    SELECT CASE lower(btrim(COALESCE(status, '')))
               WHEN 'convidado' THEN 'CONVIDADO' WHEN 'confirmado' THEN 'CONFIRMADO'
               WHEN 'não irá' THEN 'NAO_IRA' WHEN 'nao ira' THEN 'NAO_IRA'
               ELSE 'NAO_CONVIDADO' END AS chave, COUNT(*) AS qt
    FROM stg_casamento_convidado GROUP BY 1
), m AS (
    SELECT nm_status AS chave, COUNT(*) AS qt FROM casamento_convidado WHERE cd_legado IS NOT NULL GROUP BY 1
)
SELECT 'convidados/' || COALESCE(s.chave, m.chave) AS item, COALESCE(s.qt, 0) AS esperado, COALESCE(m.qt, 0) AS migrado,
       COALESCE(m.qt, 0) - COALESCE(s.qt, 0) AS diferenca
FROM s FULL JOIN m ON m.chave = s.chave ORDER BY 1;

-- 4) Convidados por grupo
WITH s AS (
    SELECT COALESCE(NULLIF(btrim(grp), ''), '(sem grupo)') AS chave, COUNT(*) AS qt FROM stg_casamento_convidado GROUP BY 1
), m AS (
    SELECT COALESCE(NULLIF(btrim(nm_grupo), ''), '(sem grupo)') AS chave, COUNT(*) AS qt
    FROM casamento_convidado WHERE cd_legado IS NOT NULL GROUP BY 1
)
SELECT 'grupo/' || COALESCE(s.chave, m.chave) AS item, COALESCE(s.qt, 0) AS esperado, COALESCE(m.qt, 0) AS migrado,
       COALESCE(m.qt, 0) - COALESCE(s.qt, 0) AS diferenca
FROM s FULL JOIN m ON m.chave = s.chave ORDER BY 1;

-- 5) Marcos: total e concluídos
SELECT 'marcos/total' AS item, (SELECT COUNT(*) FROM stg_casamento_marco) AS esperado,
       (SELECT COUNT(*) FROM casamento_marco WHERE cd_legado IS NOT NULL) AS migrado
UNION ALL
SELECT 'marcos/concluidos',
       (SELECT COUNT(*) FROM stg_casamento_marco WHERE lower(btrim(COALESCE(completed, ''))) IN ('true', 'verdadeiro', 'sim', '1', 'x')),
       (SELECT COUNT(*) FROM casamento_marco WHERE cd_legado IS NOT NULL AND in_concluido);

-- 6) Nenhum texto migrado pode começar com apóstrofo (esperado 0)
SELECT 'apostrofo residual' AS item, 0 AS esperado,
       (SELECT COUNT(*) FROM casamento_fornecedor WHERE cd_legado IS NOT NULL AND (nm_fornecedor LIKE '''%' OR tx_observacao LIKE '''%'))
     + (SELECT COUNT(*) FROM casamento_convidado WHERE cd_legado IS NOT NULL AND nm_convidado LIKE '''%')
     + (SELECT COUNT(*) FROM casamento_marco WHERE cd_legado IS NOT NULL AND (nm_titulo LIKE '''%' OR tx_observacao LIKE '''%')) AS migrado;

-- 7) Configuração
SELECT cd_chave, vl_valor FROM casamento_configuracao WHERE cd_chave IN ('casal', 'dataCasamento') ORDER BY 1;
