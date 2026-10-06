-- Migração do casamento - PASSO 3: converte o staging e grava nas tabelas definitivas.
-- SQL puro e idempotente: pode ser executado mais de uma vez sem duplicar (chave: cd_legado;
-- configuração existente não é sobrescrita). Roda numa única transação: se algo falhar, nada é gravado.

BEGIN;

-- Remove o apóstrofo inicial que a planilha põe antes de '=', '+', '-' e '@'.
CREATE OR REPLACE FUNCTION pg_temp.limpa(t TEXT) RETURNS TEXT AS $$
    SELECT NULLIF(btrim(regexp_replace(COALESCE(t, ''), '^''([=+@-])', '\1')), '')
$$ LANGUAGE SQL IMMUTABLE;

-- Id antigo: o número do CSV; sem número, a posição da linha no arquivo.
CREATE OR REPLACE FUNCTION pg_temp.legado(id TEXT, ordem BIGINT) RETURNS BIGINT AS $$
    SELECT COALESCE(NULLIF(regexp_replace(COALESCE(id, ''), '\D', '', 'g'), '')::BIGINT, ordem)
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION pg_temp.status_fornecedor(t TEXT) RETURNS TEXT AS $$
    SELECT CASE lower(btrim(COALESCE(t, '')))
        WHEN 'pesquisando' THEN 'PESQUISANDO'
        WHEN 'orçamento' THEN 'ORCAMENTO'
        WHEN 'orcamento' THEN 'ORCAMENTO'
        WHEN 'contratado' THEN 'CONTRATADO'
        WHEN '' THEN 'PESQUISANDO'
    END
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION pg_temp.status_convidado(t TEXT) RETURNS TEXT AS $$
    SELECT CASE lower(btrim(COALESCE(t, '')))
        WHEN 'não convidado' THEN 'NAO_CONVIDADO'
        WHEN 'nao convidado' THEN 'NAO_CONVIDADO'
        WHEN 'convidado' THEN 'CONVIDADO'
        WHEN 'confirmado' THEN 'CONFIRMADO'
        WHEN 'não irá' THEN 'NAO_IRA'
        WHEN 'nao ira' THEN 'NAO_IRA'
        WHEN '' THEN 'NAO_CONVIDADO'
    END
$$ LANGUAGE SQL IMMUTABLE;

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

CREATE OR REPLACE FUNCTION pg_temp.data(t TEXT) RETURNS DATE AS $$
    SELECT CASE
        WHEN LEFT(btrim(COALESCE(t, '')), 10) ~ '^\d{4}-\d{2}-\d{2}$' THEN LEFT(btrim(t), 10)::DATE
        WHEN LEFT(btrim(COALESCE(t, '')), 10) ~ '^\d{2}/\d{2}/\d{4}$' THEN to_date(LEFT(btrim(t), 10), 'DD/MM/YYYY')
    END
$$ LANGUAGE SQL IMMUTABLE;

-- Falha cedo (e desfaz tudo) se houver status desconhecido ou nome vazio.
DO $$
DECLARE
    v_ruim TEXT;
BEGIN
    SELECT string_agg(DISTINCT status, ', ') INTO v_ruim
    FROM stg_casamento_fornecedor WHERE pg_temp.status_fornecedor(status) IS NULL;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Status de fornecedor desconhecido: %', v_ruim; END IF;

    SELECT string_agg(DISTINCT status, ', ') INTO v_ruim
    FROM stg_casamento_convidado WHERE pg_temp.status_convidado(status) IS NULL;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Status de convidado desconhecido: %', v_ruim; END IF;

    SELECT string_agg('fornecedor linha ' || ordem, ', ') INTO v_ruim
    FROM stg_casamento_fornecedor WHERE pg_temp.limpa(name) IS NULL;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Nome vazio em: %', v_ruim; END IF;

    SELECT string_agg('convidado linha ' || ordem, ', ') INTO v_ruim
    FROM stg_casamento_convidado WHERE pg_temp.limpa(name) IS NULL;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Nome vazio em: %', v_ruim; END IF;

    SELECT string_agg('marco linha ' || ordem, ', ') INTO v_ruim
    FROM stg_casamento_marco WHERE pg_temp.limpa(title) IS NULL;
    IF v_ruim IS NOT NULL THEN RAISE EXCEPTION 'Título vazio em: %', v_ruim; END IF;
END $$;

INSERT INTO casamento_fornecedor (nm_fornecedor, nm_categoria, tx_contato, nm_status, vl_valor, tx_observacao, cd_legado)
SELECT pg_temp.limpa(name), COALESCE(pg_temp.limpa(category), 'Outros'), pg_temp.limpa(contact),
       pg_temp.status_fornecedor(status), GREATEST(pg_temp.numero(value), 0), pg_temp.limpa(notes),
       pg_temp.legado(id, ordem)
FROM stg_casamento_fornecedor
ON CONFLICT (cd_legado) WHERE cd_legado IS NOT NULL DO NOTHING;

-- Acompanhantes entram 0 e mesa nula (campos novos do NordTool).
INSERT INTO casamento_convidado (nm_convidado, nm_grupo, nr_telefone, nm_relacao, nm_status, nr_acompanhantes, nm_mesa, cd_legado)
SELECT pg_temp.limpa(name), pg_temp.limpa(grp), pg_temp.limpa(phone), pg_temp.limpa(relation),
       pg_temp.status_convidado(status), 0, NULL, pg_temp.legado(id, ordem)
FROM stg_casamento_convidado
ON CONFLICT (cd_legado) WHERE cd_legado IS NOT NULL DO NOTHING;

INSERT INTO casamento_marco (nm_titulo, dt_prazo, in_concluido, tx_observacao, cd_legado)
SELECT pg_temp.limpa(title), pg_temp.data(due_date),
       lower(btrim(COALESCE(completed, ''))) IN ('true', 'verdadeiro', 'sim', '1', 'x'),
       pg_temp.limpa(description), pg_temp.legado(id, ordem)
FROM stg_casamento_marco
ON CONFLICT (cd_legado) WHERE cd_legado IS NOT NULL DO NOTHING;

-- Configuração: couple -> casal, weddingDate -> dataCasamento (yyyy-MM-dd). Não sobrescreve o que já existe.
INSERT INTO casamento_configuracao (cd_chave, vl_valor)
SELECT 'casal', pg_temp.limpa(valor) FROM stg_casamento_config
WHERE btrim(chave) = 'couple' AND pg_temp.limpa(valor) IS NOT NULL
ON CONFLICT (cd_chave) DO NOTHING;

INSERT INTO casamento_configuracao (cd_chave, vl_valor)
SELECT 'dataCasamento', pg_temp.data(valor)::TEXT FROM stg_casamento_config
WHERE btrim(chave) = 'weddingDate' AND pg_temp.data(valor) IS NOT NULL
ON CONFLICT (cd_chave) DO NOTHING;

COMMIT;
