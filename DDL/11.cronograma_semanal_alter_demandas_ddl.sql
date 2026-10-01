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

-- A constraint de origem (CK01_cronograma_semanal_origem) é definida em
-- DDL/12, que já reflete a regra correta (fl_fixo exige id_dia_semana).
-- Não é recriada aqui para o replay completo do pipeline continuar
-- funcionando mesmo com demandas de Kanban/Lista sem dia nem agendamento.
