-- Migração do Financeiro - PASSO 3: converte o staging e grava em financeiro_lancamento e financeiro_mes.
-- SQL puro e idempotente: pode ser executado mais de uma vez sem duplicar (chave: cd_legado = nº da linha no CSV).
-- Roda numa única transação: se algo falhar, nada é gravado.
-- Linhas totalmente vazias são ignoradas. Linhas com dados mas incompletas/inválidas abortam tudo, listando as linhas.
-- A categoria "Saldo anterior" não vira lançamento (o saldo anterior é calculado): o valor dela só alimenta o saldo inicial do 1º mês.

BEGIN;

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

-- Mês "2026-03" ou "03/2026" -> dia 1 do mês.
CREATE OR REPLACE FUNCTION pg_temp.mes(t TEXT) RETURNS DATE AS $$
    SELECT CASE
        WHEN btrim(COALESCE(t, '')) ~ '^\d{4}-(0[1-9]|1[0-2])' THEN (LEFT(btrim(t), 7) || '-01')::DATE
        WHEN btrim(COALESCE(t, '')) ~ '^(0[1-9]|1[0-2])/\d{4}$' THEN to_date('01/' || btrim(t), 'DD/MM/YYYY')
    END
$$ LANGUAGE SQL IMMUTABLE;

-- Linhas relevantes: qualquer uma das colunas A-F preenchida.
CREATE OR REPLACE TEMP VIEW v_fin AS
SELECT ordem + 1 AS linha_planilha, pg_temp.mes(mes) AS dt_mes,
       CASE WHEN lower(btrim(tipo)) IN ('entrada', 'e') THEN 'ENTRADA'
            WHEN lower(btrim(tipo)) IN ('saida', 'saída', 's') THEN 'SAIDA' END AS cd_tipo,
       pg_temp.limpa(categoria) AS categoria, COALESCE(pg_temp.limpa(pessoa), 'Casal') AS pessoa,
       pg_temp.limpa(descricao) AS descricao, pg_temp.numero(valor) AS valor, pg_temp.data(data) AS dt_dia,
       data AS data_original, pg_temp.numero(saldo_final) AS saldo_final, pg_temp.numero(saldo_anterior) AS saldo_anterior
FROM stg_financeiro_lancamento
WHERE COALESCE(btrim(mes), '') <> '' OR COALESCE(btrim(tipo), '') <> '' OR COALESCE(btrim(categoria), '') <> ''
   OR COALESCE(btrim(valor), '') <> '';

-- Lançamentos de verdade (o "Saldo anterior" da planilha fica de fora).
CREATE OR REPLACE TEMP VIEW v_fin_lanc AS
SELECT * FROM v_fin WHERE lower(categoria) IS DISTINCT FROM 'saldo anterior';

-- Falha cedo (e desfaz tudo) apontando as linhas com problema.
DO $$
DECLARE
    v_ruim TEXT;
BEGIN
    SELECT string_agg(linha_planilha::TEXT, ', ' ORDER BY linha_planilha) INTO v_ruim FROM v_fin WHERE dt_mes IS NULL;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Mês ausente ou inválido (use 2026-03 ou 03/2026) nas linhas: %', v_ruim; END IF;

    SELECT string_agg(linha_planilha::TEXT, ', ' ORDER BY linha_planilha) INTO v_ruim FROM v_fin_lanc WHERE cd_tipo IS NULL;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Tipo deve ser Entrada ou Saída nas linhas: %', v_ruim; END IF;

    SELECT string_agg(DISTINCT format('"%s" (%s, linha %s)', v.categoria, v.cd_tipo, v.linha_planilha), '; ') INTO v_ruim
    FROM v_fin_lanc v WHERE v.categoria IS NULL
       OR NOT EXISTS (SELECT 1 FROM financeiro_categoria c WHERE lower(c.nm_categoria) = lower(v.categoria) AND c.cd_tipo = v.cd_tipo);
    IF v_ruim IS NOT NULL THEN
        RAISE EXCEPTION 'Categoria inexistente (crie em Pessoas e categorias, no Extrato, ou corrija o nome): %', v_ruim;
    END IF;

    SELECT string_agg(DISTINCT format('"%s" (linha %s)', v.pessoa, v.linha_planilha), '; ') INTO v_ruim
    FROM v_fin_lanc v WHERE NOT EXISTS (SELECT 1 FROM financeiro_pessoa p WHERE lower(p.nm_pessoa) = lower(v.pessoa));
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Pessoa inexistente (use Nick, Thaina ou Casal; vazio vira Casal): %', v_ruim; END IF;

    SELECT string_agg(linha_planilha::TEXT, ', ' ORDER BY linha_planilha) INTO v_ruim FROM v_fin_lanc WHERE valor IS NULL OR valor <= 0;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Valor ausente, inválido ou não positivo nas linhas (saídas também entram positivas): %', v_ruim; END IF;

    SELECT string_agg(linha_planilha::TEXT, ', ' ORDER BY linha_planilha) INTO v_ruim FROM v_fin_lanc
    WHERE COALESCE(btrim(data_original), '') <> '' AND dt_dia IS NULL;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Data inválida (use dd/MM/yyyy ou yyyy-MM-dd) nas linhas: %', v_ruim; END IF;

    SELECT string_agg(linha_planilha::TEXT, ', ' ORDER BY linha_planilha) INTO v_ruim FROM v_fin_lanc
    WHERE dt_dia IS NOT NULL AND date_trunc('month', dt_dia)::DATE <> dt_mes;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'A data não pertence ao mês informado nas linhas: %', v_ruim; END IF;

    SELECT string_agg(linha_planilha::TEXT, ', ' ORDER BY linha_planilha) INTO v_ruim FROM v_fin_lanc WHERE length(descricao) > 500;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Descrição com mais de 500 caracteres nas linhas: %', v_ruim; END IF;
END $$;

-- Lançamentos históricos: já recebidos/pagos. Sem data no CSV, vale o dia 1 do mês.
INSERT INTO financeiro_lancamento (dt_competencia, dt_lancamento, id_categoria, id_pessoa, ds_lancamento, vl_lancamento, in_realizado, cd_legado)
SELECT v.dt_mes, COALESCE(v.dt_dia, v.dt_mes), c.id_categoria, p.id_pessoa, v.descricao, round(v.valor, 2), TRUE, v.linha_planilha::INTEGER
FROM v_fin_lanc v
JOIN financeiro_categoria c ON lower(c.nm_categoria) = lower(v.categoria) AND c.cd_tipo = v.cd_tipo
JOIN financeiro_pessoa p ON lower(p.nm_pessoa) = lower(v.pessoa)
ON CONFLICT (cd_legado) WHERE cd_legado IS NOT NULL DO NOTHING;

-- Meses: os anteriores ao mês corrente entram fechados, com o saldo final da planilha (ou o calculado, se a planilha não trouxe).
-- O saldo inicial do 1º mês vem do "Saldo anterior" da planilha. Meses que já existem no NordTool não são alterados.
DO $$
DECLARE
    m RECORD;
    v_anterior NUMERIC := NULL;
    v_inicial NUMERIC;
    v_final NUMERIC;
    v_primeiro BOOLEAN := TRUE;
BEGIN
    FOR m IN
        SELECT dt_mes,
               COALESCE(SUM(round(valor, 2)) FILTER (WHERE cd_tipo = 'ENTRADA' AND lower(categoria) IS DISTINCT FROM 'saldo anterior'), 0) AS entradas,
               COALESCE(SUM(round(valor, 2)) FILTER (WHERE cd_tipo = 'SAIDA'), 0) AS saidas,
               MAX(saldo_final) AS saldo_final_planilha,
               MAX(saldo_anterior) AS saldo_anterior_planilha,
               MAX(CASE WHEN lower(categoria) = 'saldo anterior' THEN valor END) AS valor_linha_saldo_anterior
        FROM v_fin GROUP BY dt_mes ORDER BY dt_mes
    LOOP
        IF v_primeiro THEN
            v_inicial := COALESCE(m.saldo_anterior_planilha, m.valor_linha_saldo_anterior, 0);
            v_primeiro := FALSE;
        ELSE
            v_inicial := v_anterior;
        END IF;
        v_final := COALESCE(m.saldo_final_planilha, v_inicial + m.entradas - m.saidas);
        v_anterior := v_final;

        IF m.dt_mes < date_trunc('month', CURRENT_DATE)::DATE THEN
            INSERT INTO financeiro_mes (dt_competencia, vl_saldo_inicial, vl_saldo_final, in_fechado, dh_fechamento)
            VALUES (m.dt_mes, CASE WHEN m.dt_mes = (SELECT MIN(dt_mes) FROM v_fin) THEN v_inicial END, v_final, TRUE, NOW())
            ON CONFLICT (dt_competencia) DO NOTHING;
        ELSIF m.dt_mes = (SELECT MIN(dt_mes) FROM v_fin) THEN
            INSERT INTO financeiro_mes (dt_competencia, vl_saldo_inicial) VALUES (m.dt_mes, v_inicial)
            ON CONFLICT (dt_competencia) DO NOTHING;
        END IF;
    END LOOP;
END $$;

COMMIT;
