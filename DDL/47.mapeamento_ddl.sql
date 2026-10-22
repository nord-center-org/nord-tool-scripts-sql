-- Mapeamentos de campo e de engenharia.
--  CONTAGEM:     contagem em campo (atividades, materiais, efetivo). Usa qt_medida como "contado".
--  QUANTITATIVO: levantamento de quantitativos do projeto comparado ao medido em campo e ao solicitado
--                (ex.: pelo empreiteiro). pc_tolerancia diz quanto o medido/solicitado pode passar do projeto.

CREATE TABLE IF NOT EXISTS mapeamento (
    id_mapeamento BIGSERIAL NOT NULL,
    cd_tipo VARCHAR(20) NOT NULL,
    id_fase BIGINT NULL,
    nm_titulo VARCHAR(150) NOT NULL,
    nm_local VARCHAR(150) NULL,
    dt_mapeamento DATE NOT NULL,
    pc_tolerancia DECIMAL(5, 2) NOT NULL DEFAULT 5,
    tx_observacao VARCHAR(2000) NULL,
    cd_status VARCHAR(20) NOT NULL DEFAULT 'RASCUNHO',
    id_usuario_autor BIGINT NOT NULL,
    nr_versao INTEGER NOT NULL DEFAULT 1,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    dh_alteracao TIMESTAMP NULL,
    CONSTRAINT PK_mapeamento PRIMARY KEY (id_mapeamento),
    CONSTRAINT CK01_mapeamento_tipo CHECK (cd_tipo IN ('CONTAGEM', 'QUANTITATIVO')),
    CONSTRAINT CK02_mapeamento_status CHECK (cd_status IN ('RASCUNHO', 'CONCLUIDO')),
    CONSTRAINT CK03_mapeamento_tolerancia CHECK (pc_tolerancia >= 0 AND pc_tolerancia <= 100),
    CONSTRAINT FK01_fase_x_mapeamento FOREIGN KEY (id_fase) REFERENCES fase (id_fase),
    CONSTRAINT FK02_usuario_x_mapeamento FOREIGN KEY (id_usuario_autor) REFERENCES usuario (id_usuario)
);

CREATE INDEX IF NOT EXISTS IX01_mapeamento_fase ON mapeamento (id_fase);
CREATE INDEX IF NOT EXISTS IX02_mapeamento_data ON mapeamento (dt_mapeamento DESC);

CREATE TABLE IF NOT EXISTS mapeamento_linha (
    id_linha BIGSERIAL NOT NULL,
    id_mapeamento BIGINT NOT NULL,
    nr_ordem INTEGER NOT NULL,
    -- Agrupador livre: empresa/função na contagem de efetivo, disciplina no quantitativo.
    nm_grupo VARCHAR(80) NULL,
    nm_item VARCHAR(150) NOT NULL,
    nm_unidade VARCHAR(10) NOT NULL DEFAULT 'un',
    qt_projeto DECIMAL(15, 3) NULL,
    qt_medida DECIMAL(15, 3) NULL,
    qt_solicitada DECIMAL(15, 3) NULL,
    tx_observacao VARCHAR(500) NULL,
    CONSTRAINT PK_mapeamento_linha PRIMARY KEY (id_linha),
    CONSTRAINT CK01_mapeamento_linha_qt CHECK (
        (qt_projeto IS NULL OR qt_projeto >= 0) AND (qt_medida IS NULL OR qt_medida >= 0) AND (qt_solicitada IS NULL OR qt_solicitada >= 0)),
    CONSTRAINT FK01_mapeamento_x_linha FOREIGN KEY (id_mapeamento) REFERENCES mapeamento (id_mapeamento) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS IX01_mapeamento_linha ON mapeamento_linha (id_mapeamento, nr_ordem);
