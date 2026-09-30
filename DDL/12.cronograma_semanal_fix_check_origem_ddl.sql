ALTER TABLE cronograma_semanal
    DROP CONSTRAINT IF EXISTS CK01_cronograma_semanal_origem;

ALTER TABLE cronograma_semanal
    ADD CONSTRAINT CK01_cronograma_semanal_origem
        CHECK (fl_fixo = FALSE OR id_dia_semana IS NOT NULL);
