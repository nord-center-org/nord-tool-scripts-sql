-- Davi Job (easter egg): pontuações do minigame "Caça ao rato" para o ranking.
CREATE TABLE IF NOT EXISTS davi_job_pontuacao (
    id_pontuacao BIGSERIAL NOT NULL,
    id_usuario BIGINT NOT NULL,
    nr_pontos INTEGER NOT NULL,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_davi_job_pontuacao PRIMARY KEY (id_pontuacao),
    CONSTRAINT FK01_usuario_x_davi_job_pontuacao FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT CK01_davi_job_pontuacao_pontos CHECK (nr_pontos BETWEEN 0 AND 10000)
);

CREATE INDEX IF NOT EXISTS IX01_davi_job_pontuacao_ranking ON davi_job_pontuacao (nr_pontos DESC, dh_criacao);
CREATE INDEX IF NOT EXISTS IX02_davi_job_pontuacao_usuario ON davi_job_pontuacao (id_usuario, nr_pontos DESC);
