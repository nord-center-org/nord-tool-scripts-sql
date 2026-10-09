-- Usuários de login do app (senha em bcrypt). Diferente da tabela "users" (colaboradores do controle de chaves).
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario BIGSERIAL PRIMARY KEY,
    nm_email VARCHAR(150) NOT NULL UNIQUE,
    nm_nome VARCHAR(150) NOT NULL,
    nm_senha_hash VARCHAR(100) NOT NULL,
    id_perfil BIGINT NOT NULL REFERENCES perfil (id_perfil),
    in_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    nr_falhas_login INTEGER NOT NULL DEFAULT 0,
    dh_bloqueado_ate TIMESTAMP,
    dh_ultimo_login TIMESTAMP,
    dh_criacao TIMESTAMP NOT NULL DEFAULT now(),
    nr_versao_sessao INTEGER NOT NULL DEFAULT 0,
    dh_senha_alterada TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_usuario_email_lower ON usuario (LOWER(nm_email));

-- Versão da sessão: incrementada na troca de senha, desativação ou mudança de permissões; tokens com versão antiga deixam de valer.
ALTER TABLE usuario
    ADD COLUMN IF NOT EXISTS nr_versao_sessao INTEGER NOT NULL DEFAULT 0;

ALTER TABLE usuario
    ADD COLUMN IF NOT EXISTS dh_senha_alterada TIMESTAMP NULL;
