-- Treinos (Gestão Individual): fichas de treino de cada usuário, com exercícios e o registro de cada sessão feita.
CREATE TABLE IF NOT EXISTS treino (
    id_treino BIGSERIAL NOT NULL,
    id_usuario_dono BIGINT NOT NULL,
    nm_treino VARCHAR(80) NOT NULL,
    tx_observacao VARCHAR(500) NULL,
    -- Dias da semana sugeridos (1 = segunda … 7 = domingo), separados por vírgula. Ex.: "1,4".
    tx_dias VARCHAR(20) NULL,
    nr_ordem INTEGER NOT NULL DEFAULT 1,
    in_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    nr_versao INTEGER NOT NULL DEFAULT 1,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    dh_alteracao TIMESTAMP NULL,
    CONSTRAINT PK_treino PRIMARY KEY (id_treino),
    CONSTRAINT FK01_usuario_x_treino FOREIGN KEY (id_usuario_dono) REFERENCES usuario (id_usuario)
);

CREATE INDEX IF NOT EXISTS IX01_treino_dono ON treino (id_usuario_dono, nr_ordem);

CREATE TABLE IF NOT EXISTS treino_exercicio (
    id_exercicio BIGSERIAL NOT NULL,
    id_treino BIGINT NOT NULL,
    nr_ordem INTEGER NOT NULL,
    nm_exercicio VARCHAR(100) NOT NULL,
    nr_series SMALLINT NOT NULL DEFAULT 3,
    -- Faixa ou número de repetições. Ex.: "8-12", "15", "30s".
    tx_repeticoes VARCHAR(20) NULL,
    vl_carga DECIMAL(7, 2) NULL,
    nr_descanso_seg SMALLINT NULL,
    tx_observacao VARCHAR(300) NULL,
    CONSTRAINT PK_treino_exercicio PRIMARY KEY (id_exercicio),
    CONSTRAINT CK01_treino_exercicio CHECK (nr_series BETWEEN 1 AND 20 AND (vl_carga IS NULL OR vl_carga >= 0)
        AND (nr_descanso_seg IS NULL OR nr_descanso_seg BETWEEN 0 AND 900)),
    CONSTRAINT FK01_treino_x_exercicio FOREIGN KEY (id_treino) REFERENCES treino (id_treino) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS IX01_treino_exercicio ON treino_exercicio (id_treino, nr_ordem);

-- Cada vez que a pessoa treina: data, duração e o que fez em cada exercício (carga usada).
CREATE TABLE IF NOT EXISTS treino_sessao (
    id_sessao BIGSERIAL NOT NULL,
    id_treino BIGINT NULL,
    id_usuario_dono BIGINT NOT NULL,
    nm_treino VARCHAR(80) NOT NULL,
    dt_sessao DATE NOT NULL,
    nr_duracao_min SMALLINT NULL,
    tx_observacao VARCHAR(500) NULL,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_treino_sessao PRIMARY KEY (id_sessao),
    CONSTRAINT CK01_treino_sessao CHECK (nr_duracao_min IS NULL OR nr_duracao_min BETWEEN 0 AND 600),
    CONSTRAINT FK01_treino_x_sessao FOREIGN KEY (id_treino) REFERENCES treino (id_treino) ON DELETE SET NULL,
    CONSTRAINT FK02_usuario_x_sessao FOREIGN KEY (id_usuario_dono) REFERENCES usuario (id_usuario)
);

CREATE INDEX IF NOT EXISTS IX01_treino_sessao ON treino_sessao (id_usuario_dono, dt_sessao DESC);

CREATE TABLE IF NOT EXISTS treino_sessao_exercicio (
    id_sessao BIGINT NOT NULL,
    nr_ordem INTEGER NOT NULL,
    id_exercicio BIGINT NULL,
    nm_exercicio VARCHAR(100) NOT NULL,
    tx_repeticoes VARCHAR(20) NULL,
    vl_carga DECIMAL(7, 2) NULL,
    in_feito BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT PK_treino_sessao_exercicio PRIMARY KEY (id_sessao, nr_ordem),
    CONSTRAINT FK01_sessao_x_exercicio FOREIGN KEY (id_sessao) REFERENCES treino_sessao (id_sessao) ON DELETE CASCADE,
    CONSTRAINT FK02_exercicio_x_sessao FOREIGN KEY (id_exercicio) REFERENCES treino_exercicio (id_exercicio) ON DELETE SET NULL
);
