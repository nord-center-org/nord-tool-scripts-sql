-- Financeiro: investimentos (fundos imobiliários). Um registro por ticker e por pessoa (Nick e Thaina podem ter o mesmo FII).
-- vl_cotacao/dh_cotacao: última cotação conhecida (guardada para exibir quando o provedor de cotações estiver fora do ar).
CREATE TABLE IF NOT EXISTS financeiro_ativo (
    id_ativo BIGSERIAL NOT NULL,
    cd_ticker VARCHAR(12) NOT NULL,
    nm_ativo VARCHAR(120) NULL,
    cd_tipo VARCHAR(10) NOT NULL DEFAULT 'FII',
    id_pessoa BIGINT NOT NULL,
    vl_cotacao DECIMAL(15, 2) NULL,
    dh_cotacao TIMESTAMP NULL,
    in_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    nr_versao INTEGER NOT NULL DEFAULT 1,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_financeiro_ativo PRIMARY KEY (id_ativo),
    CONSTRAINT UK01_financeiro_ativo UNIQUE (cd_ticker, id_pessoa),
    CONSTRAINT CK01_financeiro_ativo CHECK (cd_tipo IN ('FII')),
    CONSTRAINT FK01_financeiro_pessoa_x_financeiro_ativo FOREIGN KEY (id_pessoa) REFERENCES financeiro_pessoa (id_pessoa)
);
