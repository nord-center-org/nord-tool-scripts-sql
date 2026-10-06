-- Migração da Caixinha - PASSO 3: converte o staging e grava nas tabelas definitivas.
-- SQL puro e idempotente: pode ser executado mais de uma vez sem duplicar (chave: cd_legado = nº da linha na planilha).
-- Roda numa única transação: se algo falhar, nada é gravado.
-- Linhas totalmente vazias são ignoradas. Linhas com dados mas incompletas/inválidas abortam tudo, listando as linhas.

BEGIN;

-- Remove o apóstrofo inicial que a planilha põe antes de '=', '+', '-' e '@'.
CREATE OR REPLACE FUNCTION pg_temp.limpa(t TEXT) RETURNS TEXT AS $$
    SELECT NULLIF(btrim(regexp_replace(COALESCE(t, ''), '^''([=+@-])', '\1')), '')
$$ LANGUAGE SQL IMMUTABLE;

-- Valor com ponto decimal; aceita "R$ 1.234,56" (vírgula decimal). Nulo se não for número.
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

CREATE OR REPLACE FUNCTION pg_temp.data(t TEXT) RETURNS DATE AS $$
    SELECT CASE
        WHEN LEFT(btrim(COALESCE(t, '')), 10) ~ '^\d{4}-\d{2}-\d{2}$' THEN LEFT(btrim(t), 10)::DATE
        WHEN LEFT(btrim(COALESCE(t, '')), 10) ~ '^\d{2}/\d{2}/\d{4}$' THEN to_date(LEFT(btrim(t), 10), 'DD/MM/YYYY')
    END
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION pg_temp.booleano(t TEXT) RETURNS BOOLEAN AS $$
    SELECT lower(btrim(COALESCE(t, ''))) IN ('true', 'verdadeiro', 'sim', '1', 'x')
$$ LANGUAGE SQL IMMUTABLE;

-- Linhas relevantes: qualquer uma das colunas A-F preenchida.
CREATE OR REPLACE TEMP VIEW v_caixinha AS
SELECT ordem + 1 AS linha_planilha, pg_temp.data(data) AS dt, pg_temp.limpa(responsavel) AS resp,
       pg_temp.booleano(lancado) AS lancado, pg_temp.booleano(pago) AS pago, pg_temp.limpa(insumo) AS insumo,
       pg_temp.numero(valor) AS valor, data AS data_original, valor AS valor_original
FROM stg_caixinha_lancamento
WHERE COALESCE(btrim(data), '') <> '' OR COALESCE(btrim(responsavel), '') <> '' OR COALESCE(btrim(insumo), '') <> ''
   OR COALESCE(btrim(valor), '') <> '' OR COALESCE(btrim(lancado), '') <> '' OR COALESCE(btrim(pago), '') <> '';

-- Falha cedo (e desfaz tudo) apontando as linhas da planilha com problema.
DO $$
DECLARE
    v_ruim TEXT;
BEGIN
    SELECT string_agg(linha_planilha::TEXT, ', ' ORDER BY linha_planilha) INTO v_ruim FROM v_caixinha WHERE dt IS NULL;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Data ausente ou inválida nas linhas da planilha: %', v_ruim; END IF;

    SELECT string_agg(linha_planilha::TEXT, ', ' ORDER BY linha_planilha) INTO v_ruim FROM v_caixinha WHERE resp IS NULL;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Responsável vazio nas linhas da planilha: %', v_ruim; END IF;

    SELECT string_agg(linha_planilha::TEXT, ', ' ORDER BY linha_planilha) INTO v_ruim FROM v_caixinha WHERE insumo IS NULL;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Insumo vazio nas linhas da planilha: %', v_ruim; END IF;

    SELECT string_agg(linha_planilha::TEXT, ', ' ORDER BY linha_planilha) INTO v_ruim FROM v_caixinha WHERE valor IS NULL OR valor <= 0;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Valor ausente, inválido ou não positivo nas linhas da planilha: %', v_ruim; END IF;

    SELECT string_agg(linha_planilha::TEXT, ', ' ORDER BY linha_planilha) INTO v_ruim FROM v_caixinha WHERE length(insumo) > 500 OR length(resp) > 100;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Insumo (máx. 500) ou responsável (máx. 100) longo demais nas linhas da planilha: %', v_ruim; END IF;
END $$;

-- Responsáveis distintos (sem diferenciar caixa); os já existentes são mantidos.
INSERT INTO caixinha_responsavel (nm_responsavel)
SELECT DISTINCT ON (lower(resp)) resp
FROM v_caixinha v
WHERE NOT EXISTS (SELECT 1 FROM caixinha_responsavel r WHERE lower(r.nm_responsavel) = lower(v.resp))
ORDER BY lower(resp), resp;

INSERT INTO caixinha_lancamento (dt_lancamento, id_responsavel, tx_insumo, vl_valor, in_lancado, in_pago, cd_legado)
SELECT v.dt, r.id_responsavel, v.insumo, round(v.valor, 2), v.lancado, v.pago, v.linha_planilha::INTEGER
FROM v_caixinha v
JOIN caixinha_responsavel r ON lower(r.nm_responsavel) = lower(v.resp)
ON CONFLICT (cd_legado) WHERE cd_legado IS NOT NULL DO NOTHING;

COMMIT;
