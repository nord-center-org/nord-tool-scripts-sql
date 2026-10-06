-- Migração da Caixinha - PASSO 4: conferência. Rode depois do passo 3 (a tabela de staging ainda precisa existir).
-- "esperado" = o que o CSV trazia; "migrado" = o que está em caixinha_lancamento e veio da migração (cd_legado preenchido).
-- Toda linha deve ter diferença 0. Compare também com a tela do Lugia (cartões Total, Pago e A pagar).

CREATE OR REPLACE FUNCTION pg_temp.limpa(t TEXT) RETURNS TEXT AS $$
    SELECT NULLIF(btrim(regexp_replace(COALESCE(t, ''), '^''([=+@-])', '\1')), '')
$$ LANGUAGE SQL IMMUTABLE;

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

CREATE OR REPLACE TEMP VIEW v_caixinha_csv AS
SELECT ordem + 1 AS linha_planilha, pg_temp.limpa(responsavel) AS resp, pg_temp.numero(valor) AS valor,
       lower(btrim(COALESCE(pago, ''))) IN ('true', 'verdadeiro', 'sim', '1', 'x') AS pago,
       COALESCE(btrim(link_pdf_1), '') <> '' OR COALESCE(btrim(link_pdf_2), '') <> '' OR COALESCE(btrim(link_pdf_3), '') <> '' AS tem_link_pdf
FROM stg_caixinha_lancamento
WHERE COALESCE(btrim(data), '') <> '' OR COALESCE(btrim(responsavel), '') <> '' OR COALESCE(btrim(insumo), '') <> ''
   OR COALESCE(btrim(valor), '') <> '' OR COALESCE(btrim(lancado), '') <> '' OR COALESCE(btrim(pago), '') <> '';

-- 1) Totais: nº de lançamentos, total, total pago e total a pagar
SELECT 'lancamentos' AS item, (SELECT COUNT(*) FROM v_caixinha_csv)::NUMERIC AS esperado,
       (SELECT COUNT(*) FROM caixinha_lancamento WHERE cd_legado IS NOT NULL)::NUMERIC AS migrado
UNION ALL
SELECT 'total', (SELECT COALESCE(SUM(round(valor, 2)), 0) FROM v_caixinha_csv),
       (SELECT COALESCE(SUM(vl_valor), 0) FROM caixinha_lancamento WHERE cd_legado IS NOT NULL)
UNION ALL
SELECT 'pago', (SELECT COALESCE(SUM(round(valor, 2)), 0) FROM v_caixinha_csv WHERE pago),
       (SELECT COALESCE(SUM(vl_valor), 0) FROM caixinha_lancamento WHERE cd_legado IS NOT NULL AND in_pago)
UNION ALL
SELECT 'a pagar', (SELECT COALESCE(SUM(round(valor, 2)), 0) FROM v_caixinha_csv WHERE NOT pago),
       (SELECT COALESCE(SUM(vl_valor), 0) FROM caixinha_lancamento WHERE cd_legado IS NOT NULL AND NOT in_pago);

-- 2) Por responsável (quantidade e total; sem diferenciar caixa)
WITH s AS (
    SELECT lower(resp) AS chave, COUNT(*) AS qt, SUM(round(valor, 2)) AS total FROM v_caixinha_csv GROUP BY 1
), m AS (
    SELECT lower(r.nm_responsavel) AS chave, COUNT(*) AS qt, SUM(l.vl_valor) AS total
    FROM caixinha_lancamento l JOIN caixinha_responsavel r ON r.id_responsavel = l.id_responsavel
    WHERE l.cd_legado IS NOT NULL GROUP BY 1
)
SELECT 'responsavel/' || COALESCE(s.chave, m.chave) AS item, COALESCE(s.qt, 0) AS qt_esperado, COALESCE(m.qt, 0) AS qt_migrado,
       COALESCE(s.total, 0) AS total_esperado, COALESCE(m.total, 0) AS total_migrado,
       COALESCE(m.total, 0) - COALESCE(s.total, 0) AS diferenca_total
FROM s FULL JOIN m ON m.chave = s.chave ORDER BY 1;

-- 3) Nenhum texto migrado pode começar com apóstrofo (esperado 0)
SELECT 'apostrofo residual' AS item, 0 AS esperado,
       (SELECT COUNT(*) FROM caixinha_lancamento WHERE cd_legado IS NOT NULL AND tx_insumo LIKE '''%')
     + (SELECT COUNT(*) FROM caixinha_responsavel WHERE nm_responsavel LIKE '''%') AS migrado;

-- 4) Dimensiona a decisão sobre os comprovantes antigos: lançamentos com PDF no Drive (colunas H-J)
SELECT 'lancamentos com PDF no Drive' AS item, COUNT(*) AS quantidade FROM v_caixinha_csv WHERE tem_link_pdf;
