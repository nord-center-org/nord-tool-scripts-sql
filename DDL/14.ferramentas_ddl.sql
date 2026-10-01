CREATE TABLE IF NOT EXISTS ferramentas (
    id_ferramenta SERIAL NOT NULL,
    nm_ferramenta VARCHAR(150) NOT NULL,
    nm_categoria VARCHAR(60) NULL,
    cd_patrimonio VARCHAR(60) NULL,
    fl_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    dt_inclusao TIMESTAMP NOT NULL DEFAULT NOW(),
    dt_alteracao TIMESTAMP NULL,
    CONSTRAINT PK_ferramentas PRIMARY KEY (id_ferramenta),
    CONSTRAINT UK01_ferramentas_cd_patrimonio UNIQUE (cd_patrimonio)
);

CREATE INDEX IF NOT EXISTS IDX01_ferramentas_ativo ON ferramentas (fl_ativo);
