CREATE TABLE IF NOT EXISTS ferramentas (
    id_ferramenta SERIAL NOT NULL,
    nm_ferramenta VARCHAR(150) NOT NULL,
    nm_ferramenta_categoria VARCHAR(60) NULL,
    cd_ferramenta_patrimonio VARCHAR(60) NULL,
    in_ferramenta_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    dt_inclusao TIMESTAMP NOT NULL DEFAULT NOW(),
    dt_alteracao TIMESTAMP NULL,
    CONSTRAINT PK_ferramentas PRIMARY KEY (id_ferramenta),
    CONSTRAINT UK01_ferramentas_cd_patrimonio UNIQUE (cd_ferramenta_patrimonio)
);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = current_schema() AND table_name = 'ferramentas' AND column_name = 'nm_categoria')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = current_schema() AND table_name = 'ferramentas' AND column_name = 'nm_ferramenta_categoria') THEN
        ALTER TABLE ferramentas RENAME COLUMN nm_categoria TO nm_ferramenta_categoria;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = current_schema() AND table_name = 'ferramentas' AND column_name = 'cd_patrimonio')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = current_schema() AND table_name = 'ferramentas' AND column_name = 'cd_ferramenta_patrimonio') THEN
        ALTER TABLE ferramentas RENAME COLUMN cd_patrimonio TO cd_ferramenta_patrimonio;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = current_schema() AND table_name = 'ferramentas' AND column_name = 'fl_ativo')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = current_schema() AND table_name = 'ferramentas' AND column_name = 'in_ferramenta_ativo') THEN
        ALTER TABLE ferramentas RENAME COLUMN fl_ativo TO in_ferramenta_ativo;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS IDX01_ferramentas_ativo ON ferramentas (in_ferramenta_ativo);
