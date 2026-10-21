-- Obras e fases: separam as equipes e os dados de obra (apartamentos, chaves, medições, relatórios...).
-- cd_acesso: código que o novo usuário digita no cadastro para pedir entrada na obra (o admin aprova).
CREATE TABLE IF NOT EXISTS obra (
    id_obra BIGSERIAL NOT NULL,
    nm_obra VARCHAR(120) NOT NULL,
    cd_acesso VARCHAR(20) NOT NULL,
    in_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    nr_versao INTEGER NOT NULL DEFAULT 1,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_obra PRIMARY KEY (id_obra)
);

CREATE UNIQUE INDEX IF NOT EXISTS UX01_obra_nome ON obra (LOWER(nm_obra));
CREATE UNIQUE INDEX IF NOT EXISTS UX02_obra_codigo ON obra (UPPER(cd_acesso));

-- cd_fase: sigla curta usada nos filtros e nos nomes legados (ex.: N1, N2, EN).
CREATE TABLE IF NOT EXISTS fase (
    id_fase BIGSERIAL NOT NULL,
    id_obra BIGINT NOT NULL,
    nm_fase VARCHAR(80) NOT NULL,
    cd_fase VARCHAR(10) NULL,
    nr_ordem SMALLINT NOT NULL DEFAULT 0,
    in_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    nr_versao INTEGER NOT NULL DEFAULT 1,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_fase PRIMARY KEY (id_fase),
    CONSTRAINT FK01_obra_x_fase FOREIGN KEY (id_obra) REFERENCES obra (id_obra) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS UX01_fase_nome ON fase (id_obra, LOWER(nm_fase));
CREATE UNIQUE INDEX IF NOT EXISTS UX02_fase_codigo ON fase (id_obra, UPPER(cd_fase)) WHERE cd_fase IS NOT NULL;

-- Quem participa de qual fase (só vê e mexe nos dados das fases em que está).
CREATE TABLE IF NOT EXISTS usuario_fase (
    id_usuario BIGINT NOT NULL,
    id_fase BIGINT NOT NULL,
    dh_inclusao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_usuario_fase PRIMARY KEY (id_usuario, id_fase),
    CONSTRAINT FK01_usuario_x_usuario_fase FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT FK02_fase_x_usuario_fase FOREIGN KEY (id_fase) REFERENCES fase (id_fase) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS IX01_usuario_fase_fase ON usuario_fase (id_fase);
