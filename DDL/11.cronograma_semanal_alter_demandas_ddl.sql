ALTER TABLE cronograma_semanal
    ALTER COLUMN id_dia_semana DROP NOT NULL;

ALTER TABLE cronograma_semanal
    ALTER COLUMN nm_horario TYPE VARCHAR(20);

ALTER TABLE cronograma_semanal
    ADD COLUMN IF NOT EXISTS nm_tag VARCHAR(30) NULL;

ALTER TABLE cronograma_semanal
    ADD COLUMN IF NOT EXISTS dt_agendamento TIMESTAMP NULL;

ALTER TABLE cronograma_semanal
    ADD COLUMN IF NOT EXISTS fl_fixo BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE cronograma_semanal
    DROP CONSTRAINT IF EXISTS CK01_cronograma_semanal_origem;

ALTER TABLE cronograma_semanal
    ADD CONSTRAINT CK01_cronograma_semanal_origem
        CHECK (id_dia_semana IS NOT NULL OR dt_agendamento IS NOT NULL);
