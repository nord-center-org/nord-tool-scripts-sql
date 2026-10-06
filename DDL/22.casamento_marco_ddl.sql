CREATE TABLE IF NOT EXISTS casamento_marco (
    id_marco BIGSERIAL PRIMARY KEY,
    nm_titulo VARCHAR(200) NOT NULL,
    dt_prazo DATE,
    in_concluido BOOLEAN NOT NULL DEFAULT FALSE,
    tx_observacao TEXT,
    cd_legado BIGINT,
    dh_criacao TIMESTAMP NOT NULL DEFAULT now(),
    dh_alteracao TIMESTAMP NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_casamento_marco_legado ON casamento_marco (cd_legado) WHERE cd_legado IS NOT NULL;
