-- Rotina: dias em que um compromisso fixo NÃO acontece (exceção pontual, sem apagar o compromisso).
CREATE TABLE IF NOT EXISTS cronograma_semanal_excecao (
    id_cronograma_semanal BIGINT NOT NULL,
    dt_excecao DATE NOT NULL,
    nm_usuario VARCHAR(36) NULL,
    dt_inclusao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_cronograma_semanal_excecao PRIMARY KEY (id_cronograma_semanal, dt_excecao),
    CONSTRAINT FK01_cronograma_semanal_x_excecao FOREIGN KEY (id_cronograma_semanal)
        REFERENCES cronograma_semanal (id_cronograma_semanal) ON DELETE CASCADE
);
