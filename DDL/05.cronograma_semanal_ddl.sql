CREATE TABLE IF NOT EXISTS cronograma_semanal (
    id_cronograma_semanal BIGSERIAL NOT NULL,
    id_dia_semana SMALLINT NULL,
    nm_cronograma_semanal VARCHAR(20) NOT NULL,
    nm_horario VARCHAR(5),
    nm_cronograma_categoria VARCHAR(15),
    nm_status_cronograma VARCHAR(15),
    tx_observacao VARCHAR(1000),
    dt_prazo TIMESTAMP NULL,
    dt_finalizacao TIMESTAMP NULL,
    nm_tag VARCHAR(60) NULL,
    dt_agendamento TIMESTAMP NULL,
    in_cronograma_fixo BOOLEAN NOT NULL DEFAULT TRUE,
    nm_usuario VARCHAR(36) NULL,
    dt_inclusao TIMESTAMP NOT NULL DEFAULT NOW(),
    dt_alteracao TIMESTAMP NULL,
    CONSTRAINT PK_cronograma_semanal PRIMARY KEY (id_cronograma_semanal),
    CONSTRAINT UK01_id_cronograma_semanal UNIQUE (id_cronograma_semanal),
    CONSTRAINT FK01_dia_semana_x_cronograma_semanal FOREIGN KEY (id_dia_semana) REFERENCES dia_semana (id_dia_semana)
);

-- Mantém este DDL de origem compatível com bancos que já possuem a tabela.
ALTER TABLE cronograma_semanal
    ALTER COLUMN id_dia_semana DROP NOT NULL;

ALTER TABLE cronograma_semanal
    ALTER COLUMN nm_horario TYPE VARCHAR(20);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = current_schema()
          AND table_name = 'cronograma_semanal'
          AND column_name = 'nm_categoria'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = current_schema()
          AND table_name = 'cronograma_semanal'
          AND column_name = 'nm_cronograma_categoria'
    ) THEN
        ALTER TABLE cronograma_semanal RENAME COLUMN nm_categoria TO nm_cronograma_categoria;
    END IF;
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = current_schema()
          AND table_name = 'cronograma_semanal'
          AND column_name = 'fl_fixo'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = current_schema()
          AND table_name = 'cronograma_semanal'
          AND column_name = 'in_cronograma_fixo'
    ) THEN
        ALTER TABLE cronograma_semanal RENAME COLUMN fl_fixo TO in_cronograma_fixo;
    END IF;
END $$;

ALTER TABLE cronograma_semanal
    ADD COLUMN IF NOT EXISTS nm_tag VARCHAR(60) NULL;

ALTER TABLE cronograma_semanal
    ADD COLUMN IF NOT EXISTS dt_agendamento TIMESTAMP NULL;

ALTER TABLE cronograma_semanal
    ADD COLUMN IF NOT EXISTS in_cronograma_fixo BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE cronograma_semanal
    ALTER COLUMN nm_cronograma_semanal TYPE VARCHAR(200);

ALTER TABLE cronograma_semanal
    DROP CONSTRAINT IF EXISTS CK01_cronograma_semanal_origem;
