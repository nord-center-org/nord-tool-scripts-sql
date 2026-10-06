-- cd_legado guarda o id antigo do Lugia (migração idempotente, E19).
CREATE TABLE IF NOT EXISTS casamento_fornecedor (
    id_fornecedor BIGSERIAL PRIMARY KEY,
    nm_fornecedor VARCHAR(150) NOT NULL,
    nm_categoria VARCHAR(80) NOT NULL,
    tx_contato VARCHAR(150),
    nm_status VARCHAR(20) NOT NULL DEFAULT 'PESQUISANDO',
    vl_valor NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (vl_valor >= 0),
    tx_observacao TEXT,
    cd_legado BIGINT,
    dh_criacao TIMESTAMP NOT NULL DEFAULT now(),
    dh_alteracao TIMESTAMP NOT NULL DEFAULT now(),
    CONSTRAINT ck_casamento_fornecedor_status CHECK (nm_status IN ('PESQUISANDO', 'ORCAMENTO', 'CONTRATADO'))
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_casamento_fornecedor_legado ON casamento_fornecedor (cd_legado) WHERE cd_legado IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_casamento_fornecedor_status ON casamento_fornecedor (nm_status);
