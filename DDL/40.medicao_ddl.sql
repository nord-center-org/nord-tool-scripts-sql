-- Medições de contratos (boletim de medição lançado no Sienge).
-- Título do boletim: "Boletim medição {nr_medicao} - {cd_contrato} - {nm_razao_social} - {nr_contrato}".
-- Observação (Sienge): "Obra: Medição de {vl_medicao} {tx_memorial}".
CREATE TABLE IF NOT EXISTS medicao (
    id_medicao BIGSERIAL NOT NULL,
    nr_medicao INTEGER NOT NULL,
    cd_contrato VARCHAR(20) NOT NULL,
    nm_razao_social VARCHAR(150) NOT NULL,
    nr_contrato VARCHAR(40) NOT NULL,
    dt_medicao DATE NOT NULL,
    vl_medicao DECIMAL(15, 2) NOT NULL,
    tx_memorial VARCHAR(1000) NULL,
    cd_status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
    nr_versao INTEGER NOT NULL DEFAULT 1,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    dh_alteracao TIMESTAMP NULL,
    CONSTRAINT PK_medicao PRIMARY KEY (id_medicao),
    CONSTRAINT UK01_medicao UNIQUE (nr_contrato, nr_medicao),
    CONSTRAINT CK01_medicao_numero CHECK (nr_medicao > 0),
    CONSTRAINT CK02_medicao_valor CHECK (vl_medicao > 0),
    CONSTRAINT FK01_medicao_status_x_medicao FOREIGN KEY (cd_status) REFERENCES medicao_status (cd_status)
);

CREATE INDEX IF NOT EXISTS IX01_medicao_status ON medicao (cd_status);
CREATE INDEX IF NOT EXISTS IX02_medicao_data ON medicao (dt_medicao DESC);
