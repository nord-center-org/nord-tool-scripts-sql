CREATE TABLE IF NOT EXISTS requisicoes_chaves (
    id_requisicao SERIAL NOT NULL,
    cd_retirada VARCHAR(20) NOT NULL,
    dt_retirada TIMESTAMP NOT NULL,
    dt_recebimento TIMESTAMP NULL,
    id_apartamento_vistoria BIGINT NULL,
    id_ferramenta INTEGER NULL,
    cd_tipo_item_requisicao VARCHAR(20) NOT NULL DEFAULT 'APARTAMENTO',
    id_user_retirada INTEGER NOT NULL,
    id_user_liberacao INTEGER NOT NULL,
    id_user_recebimento INTEGER NULL,
    nm_status_requisicao VARCHAR(20) NOT NULL DEFAULT 'ABERTO',
    CONSTRAINT PK_requisicoes_chaves PRIMARY KEY (id_requisicao),
    CONSTRAINT UK01_requisicoes_chaves_cd_retirada UNIQUE (cd_retirada),
    CONSTRAINT FK01_apartamento_vistoria_x_requisicoes_chaves FOREIGN KEY (id_apartamento_vistoria) REFERENCES apartamento_vistoria (id_apartamento_vistoria),
    CONSTRAINT FK05_ferramenta_x_requisicoes_chaves FOREIGN KEY (id_ferramenta) REFERENCES ferramentas (id_ferramenta),
    CONSTRAINT FK02_user_retirada_x_requisicoes_chaves FOREIGN KEY (id_user_retirada) REFERENCES users (id_user),
    CONSTRAINT FK03_user_liberacao_x_requisicoes_chaves FOREIGN KEY (id_user_liberacao) REFERENCES users (id_user),
    CONSTRAINT FK04_user_recebimento_x_requisicoes_chaves FOREIGN KEY (id_user_recebimento) REFERENCES users (id_user)
);

-- Evolui instalações existentes mantendo as alterações junto ao DDL de origem.
ALTER TABLE requisicoes_chaves
    ALTER COLUMN id_apartamento_vistoria DROP NOT NULL;

ALTER TABLE requisicoes_chaves
    ADD COLUMN IF NOT EXISTS id_ferramenta INTEGER NULL;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = current_schema()
          AND table_name = 'requisicoes_chaves'
          AND column_name = 'nm_tipo_item'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = current_schema()
          AND table_name = 'requisicoes_chaves'
          AND column_name = 'cd_tipo_item_requisicao'
    ) THEN
        ALTER TABLE requisicoes_chaves RENAME COLUMN nm_tipo_item TO cd_tipo_item_requisicao;
    END IF;
END $$;

ALTER TABLE requisicoes_chaves
    ADD COLUMN IF NOT EXISTS cd_tipo_item_requisicao VARCHAR(20) NOT NULL DEFAULT 'APARTAMENTO';

ALTER TABLE requisicoes_chaves
    DROP CONSTRAINT IF EXISTS FK05_ferramenta_x_requisicoes_chaves;

ALTER TABLE requisicoes_chaves
    ADD CONSTRAINT FK05_ferramenta_x_requisicoes_chaves
        FOREIGN KEY (id_ferramenta) REFERENCES ferramentas (id_ferramenta);

ALTER TABLE requisicoes_chaves
    DROP CONSTRAINT IF EXISTS CK01_requisicoes_chaves_tipo_item;

ALTER TABLE requisicoes_chaves
    DROP CONSTRAINT IF EXISTS CK02_requisicoes_chaves_item_unico;

CREATE INDEX IF NOT EXISTS IDX01_requisicoes_chaves_ferramenta ON requisicoes_chaves (id_ferramenta);
