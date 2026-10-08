-- Financeiro: modelo dos lançamentos fixos (apartamento, evolução de obra, investimentos...).
-- O backend gera o lançamento do mês seguinte a partir daqui. dt_fim vazio = sem data para terminar.
CREATE TABLE IF NOT EXISTS financeiro_recorrencia (
    id_recorrencia BIGSERIAL NOT NULL,
    id_categoria BIGINT NOT NULL,
    id_pessoa BIGINT NOT NULL,
    ds_recorrencia VARCHAR(500) NULL,
    vl_recorrencia DECIMAL(15, 2) NOT NULL,
    nr_dia INTEGER NULL,
    dt_inicio DATE NOT NULL,
    dt_fim DATE NULL,
    in_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    nr_versao INTEGER NOT NULL DEFAULT 1,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    dh_alteracao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_financeiro_recorrencia PRIMARY KEY (id_recorrencia),
    CONSTRAINT FK01_financeiro_categoria_x_financeiro_recorrencia FOREIGN KEY (id_categoria) REFERENCES financeiro_categoria (id_categoria),
    CONSTRAINT FK02_financeiro_pessoa_x_financeiro_recorrencia FOREIGN KEY (id_pessoa) REFERENCES financeiro_pessoa (id_pessoa)
);

CREATE INDEX IF NOT EXISTS IDX01_financeiro_recorrencia ON financeiro_recorrencia (in_ativo, dt_inicio, dt_fim);
