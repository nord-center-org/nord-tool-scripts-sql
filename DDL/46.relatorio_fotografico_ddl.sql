-- Relatório fotográfico: módulo próprio (não ligado a apartamento).
-- Modelos definem os itens que o relatório pede; ao criar um relatório os itens do modelo são copiados
-- e respondidos (fotos + observação). As fotos ficam no armazenamento comum (arquivo_armazenado).

CREATE TABLE IF NOT EXISTS relatorio_modelo (
    id_modelo BIGSERIAL NOT NULL,
    nm_modelo VARCHAR(120) NOT NULL,
    tx_descricao VARCHAR(500) NULL,
    -- Layout do PDF: quantas fotos por página.
    nr_fotos_pagina SMALLINT NOT NULL DEFAULT 2,
    in_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    nr_versao INTEGER NOT NULL DEFAULT 1,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    dh_alteracao TIMESTAMP NULL,
    CONSTRAINT PK_relatorio_modelo PRIMARY KEY (id_modelo),
    CONSTRAINT UK01_relatorio_modelo UNIQUE (nm_modelo),
    CONSTRAINT CK01_relatorio_modelo_layout CHECK (nr_fotos_pagina IN (1, 2, 4, 6))
);

CREATE TABLE IF NOT EXISTS relatorio_modelo_item (
    id_modelo_item BIGSERIAL NOT NULL,
    id_modelo BIGINT NOT NULL,
    nr_ordem INTEGER NOT NULL,
    nm_item VARCHAR(150) NOT NULL,
    tx_orientacao VARCHAR(500) NULL,
    CONSTRAINT PK_relatorio_modelo_item PRIMARY KEY (id_modelo_item),
    CONSTRAINT FK01_relatorio_modelo_x_item FOREIGN KEY (id_modelo) REFERENCES relatorio_modelo (id_modelo) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS IX01_relatorio_modelo_item ON relatorio_modelo_item (id_modelo, nr_ordem);

CREATE TABLE IF NOT EXISTS relatorio_fotografico (
    id_relatorio BIGSERIAL NOT NULL,
    id_modelo BIGINT NULL,
    id_fase BIGINT NULL,
    nm_titulo VARCHAR(150) NOT NULL,
    nm_local VARCHAR(150) NULL,
    dt_relatorio DATE NOT NULL,
    nr_fotos_pagina SMALLINT NOT NULL DEFAULT 2,
    cd_status VARCHAR(20) NOT NULL DEFAULT 'RASCUNHO',
    id_usuario_autor BIGINT NOT NULL,
    nr_versao INTEGER NOT NULL DEFAULT 1,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    dh_alteracao TIMESTAMP NULL,
    CONSTRAINT PK_relatorio_fotografico PRIMARY KEY (id_relatorio),
    CONSTRAINT CK01_relatorio_fotografico_layout CHECK (nr_fotos_pagina IN (1, 2, 4, 6)),
    CONSTRAINT CK02_relatorio_fotografico_status CHECK (cd_status IN ('RASCUNHO', 'CONCLUIDO')),
    CONSTRAINT FK01_relatorio_modelo_x_relatorio FOREIGN KEY (id_modelo) REFERENCES relatorio_modelo (id_modelo) ON DELETE SET NULL,
    CONSTRAINT FK02_fase_x_relatorio FOREIGN KEY (id_fase) REFERENCES fase (id_fase),
    CONSTRAINT FK03_usuario_x_relatorio FOREIGN KEY (id_usuario_autor) REFERENCES usuario (id_usuario)
);

CREATE INDEX IF NOT EXISTS IX01_relatorio_fotografico_fase ON relatorio_fotografico (id_fase);
CREATE INDEX IF NOT EXISTS IX02_relatorio_fotografico_data ON relatorio_fotografico (dt_relatorio DESC);

CREATE TABLE IF NOT EXISTS relatorio_fotografico_item (
    id_relatorio_item BIGSERIAL NOT NULL,
    id_relatorio BIGINT NOT NULL,
    nr_ordem INTEGER NOT NULL,
    nm_item VARCHAR(150) NOT NULL,
    tx_orientacao VARCHAR(500) NULL,
    -- Resposta de quem preencheu (observação do item).
    tx_resposta VARCHAR(2000) NULL,
    CONSTRAINT PK_relatorio_fotografico_item PRIMARY KEY (id_relatorio_item),
    CONSTRAINT FK01_relatorio_x_item FOREIGN KEY (id_relatorio) REFERENCES relatorio_fotografico (id_relatorio) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS IX01_relatorio_fotografico_item ON relatorio_fotografico_item (id_relatorio, nr_ordem);

CREATE TABLE IF NOT EXISTS relatorio_foto (
    id_foto BIGSERIAL NOT NULL,
    id_relatorio_item BIGINT NOT NULL,
    id_arquivo BIGINT NOT NULL,
    nr_ordem INTEGER NOT NULL,
    tx_legenda VARCHAR(300) NULL,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_relatorio_foto PRIMARY KEY (id_foto),
    CONSTRAINT UK01_relatorio_foto_arquivo UNIQUE (id_arquivo),
    CONSTRAINT FK01_relatorio_item_x_foto FOREIGN KEY (id_relatorio_item) REFERENCES relatorio_fotografico_item (id_relatorio_item) ON DELETE CASCADE,
    CONSTRAINT FK02_arquivo_x_foto FOREIGN KEY (id_arquivo) REFERENCES arquivo_armazenado (id_arquivo)
);

CREATE INDEX IF NOT EXISTS IX01_relatorio_foto ON relatorio_foto (id_relatorio_item, nr_ordem);
