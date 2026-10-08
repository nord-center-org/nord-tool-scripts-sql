-- Financeiro: um registro por mês (dt_competencia = dia 1). Guarda o saldo inicial informado e o fechamento.
-- vl_saldo_inicial só é usado no primeiro mês (ou para corrigir); nos demais o saldo anterior vem do mês anterior.
-- vl_saldo_final é gravado ao fechar o mês e passa a ser o saldo anterior do mês seguinte.
CREATE TABLE IF NOT EXISTS financeiro_mes (
    id_mes BIGSERIAL NOT NULL,
    dt_competencia DATE NOT NULL,
    vl_saldo_inicial DECIMAL(15, 2) NULL,
    vl_saldo_final DECIMAL(15, 2) NULL,
    in_fechado BOOLEAN NOT NULL DEFAULT FALSE,
    dh_fechamento TIMESTAMP NULL,
    id_usuario_fechamento BIGINT NULL,
    nr_versao INTEGER NOT NULL DEFAULT 1,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    dh_alteracao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_financeiro_mes PRIMARY KEY (id_mes),
    CONSTRAINT UK01_financeiro_mes UNIQUE (dt_competencia),
    CONSTRAINT FK01_usuario_x_financeiro_mes FOREIGN KEY (id_usuario_fechamento) REFERENCES usuario (id_usuario)
);
