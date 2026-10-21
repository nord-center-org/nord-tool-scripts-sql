-- Medições: status possíveis. Para criar um novo status basta inserir uma linha (DML/06 mostra o formato);
-- in_ativo = FALSE tira o status das opções novas sem perder as medições que já o usam.
CREATE TABLE IF NOT EXISTS medicao_status (
    cd_status VARCHAR(20) NOT NULL,
    nm_status VARCHAR(30) NOT NULL,
    nr_ordem SMALLINT NOT NULL DEFAULT 0,
    in_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT PK_medicao_status PRIMARY KEY (cd_status),
    CONSTRAINT UK01_medicao_status UNIQUE (nm_status)
);
