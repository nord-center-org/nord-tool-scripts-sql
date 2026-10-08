-- Financeiro: proventos (dividendos/rendimentos) por cota de cada fundo.
-- dt_com: data-com (quem tem cotas ao fim desse dia recebe); dt_pagamento: data prevista/efetiva do pagamento.
-- O valor a receber = cotas na data-com x vl_por_cota (calculado pela API). cd_origem: MANUAL ou COTACAO (importado do provedor).
CREATE TABLE IF NOT EXISTS financeiro_provento (
    id_provento BIGSERIAL NOT NULL,
    id_ativo BIGINT NOT NULL,
    dt_com DATE NOT NULL,
    dt_pagamento DATE NOT NULL,
    vl_por_cota DECIMAL(15, 6) NOT NULL,
    cd_origem VARCHAR(10) NOT NULL DEFAULT 'MANUAL',
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_financeiro_provento PRIMARY KEY (id_provento),
    CONSTRAINT UK01_financeiro_provento UNIQUE (id_ativo, dt_com),
    CONSTRAINT CK01_financeiro_provento CHECK (vl_por_cota > 0),
    CONSTRAINT CK02_financeiro_provento CHECK (cd_origem IN ('MANUAL', 'COTACAO')),
    CONSTRAINT FK01_financeiro_ativo_x_financeiro_provento FOREIGN KEY (id_ativo) REFERENCES financeiro_ativo (id_ativo)
);
