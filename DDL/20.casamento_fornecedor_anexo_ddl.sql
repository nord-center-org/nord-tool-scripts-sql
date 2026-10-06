-- Contratos/comprovantes do fornecedor. O CASCADE apaga as linhas; os registros de arquivo_armazenado
-- são apagados explicitamente pela aplicação.
CREATE TABLE IF NOT EXISTS casamento_fornecedor_anexo (
    id_anexo BIGSERIAL PRIMARY KEY,
    id_fornecedor BIGINT NOT NULL REFERENCES casamento_fornecedor (id_fornecedor) ON DELETE CASCADE,
    id_arquivo BIGINT NOT NULL REFERENCES arquivo_armazenado (id_arquivo),
    tx_descricao VARCHAR(200),
    dh_criacao TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_casamento_anexo_fornecedor ON casamento_fornecedor_anexo (id_fornecedor);
