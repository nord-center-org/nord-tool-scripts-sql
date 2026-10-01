ALTER TABLE requisicoes_chaves
    ALTER COLUMN id_apartamento_vistoria DROP NOT NULL;

ALTER TABLE requisicoes_chaves
    ADD COLUMN IF NOT EXISTS id_ferramenta INTEGER NULL;

ALTER TABLE requisicoes_chaves
    ADD COLUMN IF NOT EXISTS nm_tipo_item VARCHAR(20) NOT NULL DEFAULT 'APARTAMENTO';

ALTER TABLE requisicoes_chaves
    DROP CONSTRAINT IF EXISTS FK05_ferramenta_x_requisicoes_chaves;

ALTER TABLE requisicoes_chaves
    ADD CONSTRAINT FK05_ferramenta_x_requisicoes_chaves
        FOREIGN KEY (id_ferramenta) REFERENCES ferramentas (id_ferramenta);

ALTER TABLE requisicoes_chaves
    DROP CONSTRAINT IF EXISTS CK01_requisicoes_chaves_tipo_item;

ALTER TABLE requisicoes_chaves
    ADD CONSTRAINT CK01_requisicoes_chaves_tipo_item
        CHECK (nm_tipo_item IN ('APARTAMENTO', 'FERRAMENTA'));

ALTER TABLE requisicoes_chaves
    DROP CONSTRAINT IF EXISTS CK02_requisicoes_chaves_item_unico;

ALTER TABLE requisicoes_chaves
    ADD CONSTRAINT CK02_requisicoes_chaves_item_unico
        CHECK (
            (nm_tipo_item = 'APARTAMENTO' AND id_apartamento_vistoria IS NOT NULL AND id_ferramenta IS NULL)
            OR
            (nm_tipo_item = 'FERRAMENTA' AND id_ferramenta IS NOT NULL AND id_apartamento_vistoria IS NULL)
        );

CREATE INDEX IF NOT EXISTS IDX01_requisicoes_chaves_ferramenta ON requisicoes_chaves (id_ferramenta);
