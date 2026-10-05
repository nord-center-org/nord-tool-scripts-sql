-- Armazenamento provisório de arquivos (provedor POSTGRES). O provedor definitivo ainda será decidido;
-- nm_provedor e cd_referencia já preveem um provedor externo (Drive/S3).
CREATE TABLE IF NOT EXISTS arquivo_armazenado (
    id_arquivo BIGSERIAL PRIMARY KEY,
    nm_provedor VARCHAR(20) NOT NULL DEFAULT 'POSTGRES',
    cd_referencia VARCHAR(500),
    nm_arquivo VARCHAR(255) NOT NULL,
    nm_content_type VARCHAR(100) NOT NULL,
    nr_tamanho_bytes BIGINT NOT NULL,
    nm_hash_sha256 CHAR(64) NOT NULL,
    bin_conteudo BYTEA,
    dh_criacao TIMESTAMP NOT NULL DEFAULT now()
);
