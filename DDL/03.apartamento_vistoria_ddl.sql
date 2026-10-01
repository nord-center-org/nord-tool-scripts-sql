CREATE TABLE IF NOT EXISTS apartamento_vistoria (
    id_apartamento_vistoria BIGSERIAL NOT NULL,
    nm_apartamento_vistoria VARCHAR(10) NOT NULL,
    id_dia_semana SMALLINT NOT NULL,
    dt_apartamento_vigente DATE,
    nm_horario_vistoria VARCHAR(5),
    id_status_vistoria SMALLINT NOT NULL,
    in_marcar_revistoria BOOLEAN DEFAULT FALSE,
    tx_observacao_revistoria TEXT,
    dt_revistoria_vigente DATE,
    dt_inclusao TIMESTAMP NOT NULL,
    dt_alteracao TIMESTAMP NULL,
    nm_usuario VARCHAR(36) NULL,
    cd_transacao VARCHAR(36) NULL,
    nm_status_andamento_vistoria VARCHAR(20) NULL,
    CONSTRAINT PK_apartamento_vistoria PRIMARY KEY (id_apartamento_vistoria),
    CONSTRAINT UK01_apartamento_vistoria UNIQUE (id_apartamento_vistoria),
    CONSTRAINT FK01_dia_semana_x_apartamento_vistoria FOREIGN KEY (id_dia_semana) REFERENCES dia_semana (id_dia_semana),
    CONSTRAINT FK02_status_vistoria_x_apartamento_vistoria FOREIGN KEY (id_status_vistoria) REFERENCES status_vistoria (id_status_vistoria)
);

ALTER TABLE apartamento_vistoria ADD COLUMN 
IF NOT EXISTS dt_inclusao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE apartamento_vistoria ADD COLUMN 
IF NOT EXISTS dt_alteracao TIMESTAMP NULL;

ALTER TABLE apartamento_vistoria ADD COLUMN 
IF NOT EXISTS nm_usuario VARCHAR(36) NULL;

ALTER TABLE apartamento_vistoria ADD COLUMN 
IF NOT EXISTS nm_status_andamento_vistoria VARCHAR(20) NULL;

ALTER TABLE apartamento_vistoria ADD COLUMN 
IF NOT EXISTS cd_transacao VARCHAR(36) NULL;

CREATE INDEX IF NOT EXISTS IDX01_apartamento_vistoria
ON apartamento_vistoria(id_dia_semana);

CREATE INDEX IF NOT EXISTS IDX02_apartamento_vistoria
ON apartamento_vistoria(id_status_vistoria);
