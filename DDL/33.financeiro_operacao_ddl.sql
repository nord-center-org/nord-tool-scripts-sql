-- Financeiro: compras e vendas de cotas. A posição (cotas e preço médio) é calculada a partir delas.
-- vl_preco é o preço por cota. cd_requisicao: idempotência na criação (reenviar o mesmo UUID não duplica).
CREATE TABLE IF NOT EXISTS financeiro_operacao (
    id_operacao BIGSERIAL NOT NULL,
    cd_requisicao UUID NULL,
    id_ativo BIGINT NOT NULL,
    dt_operacao DATE NOT NULL,
    cd_tipo VARCHAR(10) NOT NULL,
    qt_cotas INTEGER NOT NULL,
    vl_preco DECIMAL(15, 2) NOT NULL,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_financeiro_operacao PRIMARY KEY (id_operacao),
    CONSTRAINT UK01_financeiro_operacao UNIQUE (cd_requisicao),
    CONSTRAINT CK01_financeiro_operacao CHECK (cd_tipo IN ('COMPRA', 'VENDA')),
    CONSTRAINT CK02_financeiro_operacao CHECK (qt_cotas > 0 AND vl_preco > 0),
    CONSTRAINT FK01_financeiro_ativo_x_financeiro_operacao FOREIGN KEY (id_ativo) REFERENCES financeiro_ativo (id_ativo)
);
CREATE INDEX IF NOT EXISTS IDX01_financeiro_operacao ON financeiro_operacao (id_ativo, dt_operacao);
