-- Caixinha individual: cada lançamento e cada responsável pertence a um usuário (o dono).
-- Registros antigos ficam sem dono (NULL) e só aparecem para quem é Admin do módulo Caixinha.
ALTER TABLE caixinha_responsavel ADD COLUMN IF NOT EXISTS id_usuario_dono BIGINT NULL;
ALTER TABLE caixinha_lancamento ADD COLUMN IF NOT EXISTS id_usuario_dono BIGINT NULL;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_caixinha_responsavel_dono') THEN
        ALTER TABLE caixinha_responsavel ADD CONSTRAINT fk_caixinha_responsavel_dono FOREIGN KEY (id_usuario_dono) REFERENCES usuario (id_usuario);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_caixinha_lancamento_dono') THEN
        ALTER TABLE caixinha_lancamento ADD CONSTRAINT fk_caixinha_lancamento_dono FOREIGN KEY (id_usuario_dono) REFERENCES usuario (id_usuario);
    END IF;
END $$;

-- O nome do responsável passa a ser único por dono (duas pessoas podem ter um "João" cada).
ALTER TABLE caixinha_responsavel DROP CONSTRAINT IF EXISTS caixinha_responsavel_nm_responsavel_key;
CREATE UNIQUE INDEX IF NOT EXISTS ux_caixinha_responsavel_dono_nome
    ON caixinha_responsavel (COALESCE(id_usuario_dono, 0), LOWER(nm_responsavel));

CREATE INDEX IF NOT EXISTS ix_caixinha_lancamento_dono ON caixinha_lancamento (id_usuario_dono, dt_lancamento DESC);
