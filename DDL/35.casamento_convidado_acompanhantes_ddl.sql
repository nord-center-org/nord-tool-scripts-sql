-- Casamento: família. Um convidado pode ser ligado a outro (quem ele acompanha); quem está ligado aparece em cascata
-- embaixo do principal. nr_acompanhantes continua sendo a quantidade de acompanhantes sem cadastro.
-- Se o convidado principal for excluído, os ligados a ele ficam sem ligação.
ALTER TABLE casamento_convidado
    ADD COLUMN IF NOT EXISTS id_convidado_principal BIGINT NULL
        REFERENCES casamento_convidado (id_convidado) ON DELETE SET NULL
        CHECK (id_convidado_principal IS NULL OR id_convidado_principal <> id_convidado);

CREATE INDEX IF NOT EXISTS ix_casamento_convidado_principal ON casamento_convidado (id_convidado_principal);
