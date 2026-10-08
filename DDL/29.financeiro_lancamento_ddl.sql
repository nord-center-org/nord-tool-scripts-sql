-- Financeiro: lançamentos de entrada e saída.
-- dt_competencia = dia 1 do mês a que o lançamento pertence; dt_lancamento = data do fato (vencimento/recebimento).
-- in_realizado: FALSE = previsto; TRUE = já recebido/pago.
-- id_usuario_criacao = quem digitou (login); id_pessoa = de quem é o lançamento.
-- cd_requisicao: idempotência na criação (reenviar o mesmo UUID não duplica).
-- nr_parcela/qt_parcela: preenchidos nos lançamentos parcelados. cd_legado: nº da linha na planilha (migração).
CREATE TABLE IF NOT EXISTS financeiro_lancamento (
    id_lancamento BIGSERIAL NOT NULL,
    cd_requisicao UUID NULL,
    dt_competencia DATE NOT NULL,
    dt_lancamento DATE NOT NULL,
    id_categoria BIGINT NOT NULL,
    id_pessoa BIGINT NOT NULL,
    ds_lancamento VARCHAR(500) NULL,
    vl_lancamento DECIMAL(15, 2) NOT NULL,
    in_realizado BOOLEAN NOT NULL DEFAULT FALSE,
    id_recorrencia BIGINT NULL,
    nr_parcela INTEGER NULL,
    qt_parcela INTEGER NULL,
    id_usuario_criacao BIGINT NULL,
    cd_legado INTEGER NULL,
    nr_versao INTEGER NOT NULL DEFAULT 1,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    dh_alteracao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_financeiro_lancamento PRIMARY KEY (id_lancamento),
    CONSTRAINT UK01_financeiro_lancamento UNIQUE (cd_requisicao),
    CONSTRAINT FK01_financeiro_categoria_x_financeiro_lancamento FOREIGN KEY (id_categoria) REFERENCES financeiro_categoria (id_categoria),
    CONSTRAINT FK02_financeiro_pessoa_x_financeiro_lancamento FOREIGN KEY (id_pessoa) REFERENCES financeiro_pessoa (id_pessoa),
    CONSTRAINT FK03_financeiro_recorrencia_x_financeiro_lancamento FOREIGN KEY (id_recorrencia) REFERENCES financeiro_recorrencia (id_recorrencia),
    CONSTRAINT FK04_usuario_x_financeiro_lancamento FOREIGN KEY (id_usuario_criacao) REFERENCES usuario (id_usuario)
);

-- Extrato e dashboard: filtram por mês (e por pessoa) e por categoria dentro do mês.
CREATE INDEX IF NOT EXISTS IDX01_financeiro_lancamento ON financeiro_lancamento (dt_competencia, id_pessoa);
CREATE INDEX IF NOT EXISTS IDX02_financeiro_lancamento ON financeiro_lancamento (id_categoria, dt_competencia);
-- Geração da recorrência do mês seguinte: "esta recorrência já tem lançamento neste mês?"
CREATE INDEX IF NOT EXISTS IDX03_financeiro_lancamento ON financeiro_lancamento (id_recorrencia, dt_competencia);
CREATE UNIQUE INDEX IF NOT EXISTS UK02_financeiro_lancamento ON financeiro_lancamento (cd_legado) WHERE cd_legado IS NOT NULL;
