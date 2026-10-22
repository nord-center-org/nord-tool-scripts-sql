-- Cronograma pessoal: cada compromisso/demanda tem dono e pode ser compartilhado com colegas ou com a equipe.
-- Itens antigos ficam sem dono (NULL) e só aparecem para quem é Admin do módulo Cronograma.
ALTER TABLE cronograma_semanal ADD COLUMN IF NOT EXISTS id_usuario_dono BIGINT NULL;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_cronograma_semanal_dono') THEN
        ALTER TABLE cronograma_semanal ADD CONSTRAINT fk_cronograma_semanal_dono FOREIGN KEY (id_usuario_dono) REFERENCES usuario (id_usuario);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS ix_cronograma_semanal_dono ON cronograma_semanal (id_usuario_dono);

-- Com quem o dono compartilhou o item (quem recebe vê, mas só o dono altera).
CREATE TABLE IF NOT EXISTS cronograma_compartilhamento (
    id_cronograma_semanal BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    dh_inclusao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_cronograma_compartilhamento PRIMARY KEY (id_cronograma_semanal, id_usuario),
    CONSTRAINT FK01_cronograma_x_compartilhamento FOREIGN KEY (id_cronograma_semanal)
        REFERENCES cronograma_semanal (id_cronograma_semanal) ON DELETE CASCADE,
    CONSTRAINT FK02_usuario_x_compartilhamento FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

CREATE INDEX IF NOT EXISTS ix_cronograma_compartilhamento_usuario ON cronograma_compartilhamento (id_usuario);
