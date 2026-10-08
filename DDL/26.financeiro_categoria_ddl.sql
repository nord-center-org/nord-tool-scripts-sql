-- Financeiro: categorias de entrada e saída e a regra usada na projeção do mês.
-- cd_tipo: ENTRADA | SAIDA.
-- cd_projecao: FIXA_MEDIA | SALDO_ANTERIOR | FIXA_VALOR | RITMO_FATURA | VARIAVEL_MEDIA | MANUAL (validados no backend).
-- cd_regra_data/nr_dia: quando a entrada costuma cair (DIA_MES = dia do mês; DIA_UTIL = n-ésimo dia útil).
CREATE TABLE IF NOT EXISTS financeiro_categoria (
    id_categoria BIGSERIAL NOT NULL,
    nm_categoria VARCHAR(100) NOT NULL,
    cd_tipo VARCHAR(10) NOT NULL,
    cd_projecao VARCHAR(20) NOT NULL,
    in_fixa BOOLEAN NOT NULL DEFAULT FALSE,
    cd_regra_data VARCHAR(10) NULL,
    nr_dia INTEGER NULL,
    nr_ordem INTEGER NOT NULL DEFAULT 0,
    in_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_financeiro_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT UK01_financeiro_categoria UNIQUE (nm_categoria, cd_tipo)
);
