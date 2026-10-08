-- Financeiro: histórico do valor parcial da fatura do cartão ao longo do mês.
-- Cada vez que a fatura é atualizada grava-se uma leitura (no máximo uma por dia: a última do dia vale).
-- A projeção da fatura usa essas leituras para medir o ritmo de gasto.
CREATE TABLE IF NOT EXISTS financeiro_fatura_leitura (
    id_leitura BIGSERIAL NOT NULL,
    id_lancamento BIGINT NOT NULL,
    dt_leitura DATE NOT NULL,
    vl_leitura DECIMAL(15, 2) NOT NULL,
    id_usuario BIGINT NULL,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_financeiro_fatura_leitura PRIMARY KEY (id_leitura),
    CONSTRAINT UK01_financeiro_fatura_leitura UNIQUE (id_lancamento, dt_leitura),
    CONSTRAINT FK01_financeiro_lancamento_x_financeiro_fatura_leitura FOREIGN KEY (id_lancamento) REFERENCES financeiro_lancamento (id_lancamento) ON DELETE CASCADE,
    CONSTRAINT FK02_usuario_x_financeiro_fatura_leitura FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);
