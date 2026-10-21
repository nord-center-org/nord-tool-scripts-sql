-- Cadastro pelo próprio usuário (com o código da obra) e aprovação do admin.
-- cd_situacao_cadastro: PENDENTE (aguardando aprovação), APROVADO ou RECUSADO. Usuários já existentes ficam APROVADO.
ALTER TABLE usuario ADD COLUMN IF NOT EXISTS cd_situacao_cadastro VARCHAR(20) NOT NULL DEFAULT 'APROVADO';
ALTER TABLE usuario ADD COLUMN IF NOT EXISTS id_obra_solicitada BIGINT NULL;
ALTER TABLE usuario ADD COLUMN IF NOT EXISTS dh_decisao_cadastro TIMESTAMP NULL;

ALTER TABLE usuario DROP CONSTRAINT IF EXISTS CK01_usuario_situacao_cadastro;
ALTER TABLE usuario ADD CONSTRAINT CK01_usuario_situacao_cadastro
    CHECK (cd_situacao_cadastro IN ('PENDENTE', 'APROVADO', 'RECUSADO'));
ALTER TABLE usuario DROP CONSTRAINT IF EXISTS FK05_obra_solicitada_x_usuario;
ALTER TABLE usuario ADD CONSTRAINT FK05_obra_solicitada_x_usuario
    FOREIGN KEY (id_obra_solicitada) REFERENCES obra (id_obra) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS IX01_usuario_situacao_cadastro ON usuario (cd_situacao_cadastro);

-- "Esqueci a senha": o link enviado por e-mail leva um token aleatório; aqui só fica o SHA-256 dele.
-- Vale 30 minutos e uma única vez (dh_uso preenchido = já usado).
CREATE TABLE IF NOT EXISTS senha_redefinicao (
    id_senha_redefinicao BIGSERIAL NOT NULL,
    id_usuario BIGINT NOT NULL,
    nm_token_hash CHAR(64) NOT NULL,
    dh_expira TIMESTAMP NOT NULL,
    dh_uso TIMESTAMP NULL,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_senha_redefinicao PRIMARY KEY (id_senha_redefinicao),
    CONSTRAINT UK01_senha_redefinicao_token UNIQUE (nm_token_hash),
    CONSTRAINT FK01_usuario_x_senha_redefinicao FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS IX01_senha_redefinicao_usuario ON senha_redefinicao (id_usuario);
