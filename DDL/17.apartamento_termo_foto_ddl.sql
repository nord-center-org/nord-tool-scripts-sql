CREATE TABLE IF NOT EXISTS apartamento_termo_foto (
    id_termo_foto BIGSERIAL PRIMARY KEY,
    id_termo_reprova BIGINT NOT NULL REFERENCES apartamento_termo_reprova (id_termo_reprova) ON DELETE CASCADE,
    nr_pagina INTEGER NOT NULL CHECK (nr_pagina > 0),
    nr_ordem INTEGER NOT NULL DEFAULT 0,
    tx_legenda VARCHAR(240),
    id_arquivo_imagem BIGINT NOT NULL REFERENCES arquivo_armazenado (id_arquivo),
    id_arquivo_miniatura BIGINT NOT NULL REFERENCES arquivo_armazenado (id_arquivo),
    dh_criacao TIMESTAMP NOT NULL DEFAULT now(),
    dh_alteracao TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_termo_foto_pagina ON apartamento_termo_foto (id_termo_reprova, nr_pagina, nr_ordem);
