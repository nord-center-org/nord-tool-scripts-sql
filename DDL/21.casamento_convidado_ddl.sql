CREATE TABLE IF NOT EXISTS casamento_convidado (
    id_convidado BIGSERIAL PRIMARY KEY,
    nm_convidado VARCHAR(150) NOT NULL,
    nm_grupo VARCHAR(80),
    nr_telefone VARCHAR(30),
    nm_relacao VARCHAR(80),
    nm_status VARCHAR(20) NOT NULL DEFAULT 'NAO_CONVIDADO',
    nr_acompanhantes INTEGER NOT NULL DEFAULT 0 CHECK (nr_acompanhantes >= 0),
    nm_mesa VARCHAR(40),
    cd_legado BIGINT,
    dh_criacao TIMESTAMP NOT NULL DEFAULT now(),
    dh_alteracao TIMESTAMP NOT NULL DEFAULT now(),
    CONSTRAINT ck_casamento_convidado_status CHECK (nm_status IN ('NAO_CONVIDADO', 'CONVIDADO', 'CONFIRMADO', 'NAO_IRA'))
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_casamento_convidado_legado ON casamento_convidado (cd_legado) WHERE cd_legado IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_casamento_convidado_status ON casamento_convidado (nm_status);
