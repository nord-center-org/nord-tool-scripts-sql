-- Caixinha (Gestão Individual): responsáveis, lançamentos de despesas e comprovantes em PDF.
CREATE TABLE IF NOT EXISTS caixinha_responsavel (
    id_responsavel BIGSERIAL PRIMARY KEY,
    nm_responsavel VARCHAR(100) NOT NULL UNIQUE,
    in_ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS caixinha_lancamento (
    id_lancamento BIGSERIAL PRIMARY KEY,
    -- idempotência na criação: reenviar o mesmo cd_requisicao não duplica
    cd_requisicao UUID UNIQUE,
    dt_lancamento DATE NOT NULL,
    id_responsavel BIGINT NOT NULL REFERENCES caixinha_responsavel (id_responsavel),
    tx_insumo VARCHAR(500) NOT NULL,
    vl_valor NUMERIC(12, 2) NOT NULL CHECK (vl_valor > 0),
    in_lancado BOOLEAN NOT NULL DEFAULT FALSE,
    in_pago BOOLEAN NOT NULL DEFAULT FALSE,
    -- controle de concorrência (revisão): incrementa a cada alteração
    nr_versao INTEGER NOT NULL DEFAULT 1,
    -- nº da linha na planilha do Lugia (migração)
    cd_legado INTEGER,
    dh_criacao TIMESTAMP NOT NULL DEFAULT now(),
    dh_alteracao TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_caixinha_data ON caixinha_lancamento (dt_lancamento DESC);
CREATE UNIQUE INDEX IF NOT EXISTS ux_caixinha_lancamento_legado ON caixinha_lancamento (cd_legado) WHERE cd_legado IS NOT NULL;

-- ON DELETE CASCADE apaga as linhas, mas NÃO os registros de arquivo_armazenado:
-- a aplicação apaga os arquivos explicitamente.
CREATE TABLE IF NOT EXISTS caixinha_comprovante (
    id_comprovante BIGSERIAL PRIMARY KEY,
    id_lancamento BIGINT NOT NULL REFERENCES caixinha_lancamento (id_lancamento) ON DELETE CASCADE,
    id_arquivo BIGINT NOT NULL REFERENCES arquivo_armazenado (id_arquivo),
    -- envio idempotente
    cd_requisicao UUID UNIQUE,
    dh_criacao TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_caixinha_comprovante_lancamento ON caixinha_comprovante (id_lancamento);
