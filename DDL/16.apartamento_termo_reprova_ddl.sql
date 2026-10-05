-- ON DELETE CASCADE apaga as linhas, mas NÃO os registros de arquivo_armazenado:
-- a aplicação apaga os arquivos explicitamente.
CREATE TABLE IF NOT EXISTS apartamento_termo_reprova (
    id_termo_reprova BIGSERIAL PRIMARY KEY,
    id_apartamento_vistoria BIGINT NOT NULL REFERENCES apartamento_vistoria (id_apartamento_vistoria) ON DELETE CASCADE,
    nr_termo INTEGER NOT NULL,
    id_arquivo BIGINT NOT NULL REFERENCES arquivo_armazenado (id_arquivo),
    nr_paginas INTEGER NOT NULL CHECK (nr_paginas > 0 AND nr_paginas <= 40),
    nm_situacao VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
    tx_observacao TEXT,
    dh_criacao TIMESTAMP NOT NULL DEFAULT now(),
    dh_alteracao TIMESTAMP NOT NULL DEFAULT now(),
    CONSTRAINT uq_termo_apartamento_nr UNIQUE (id_apartamento_vistoria, nr_termo)
);
