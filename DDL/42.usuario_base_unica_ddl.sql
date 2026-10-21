-- Base única de usuários: o login (usuario) passa a ter os dados de colaborador (celular, empresa, cargo)
-- e o controle de chaves passa a referenciar usuario. A tabela users (colaboradores antigos) vira histórico:
-- cada colaborador antigo pode ser vinculado a um usuário (id_user_legado) para não perder o histórico.
ALTER TABLE usuario ADD COLUMN IF NOT EXISTS nm_celular VARCHAR(20) NULL;
ALTER TABLE usuario ADD COLUMN IF NOT EXISTS id_empresa INTEGER NULL;
ALTER TABLE usuario ADD COLUMN IF NOT EXISTS id_cargo INTEGER NULL;
ALTER TABLE usuario ADD COLUMN IF NOT EXISTS id_user_legado INTEGER NULL;

ALTER TABLE usuario DROP CONSTRAINT IF EXISTS FK02_empresa_x_usuario;
ALTER TABLE usuario ADD CONSTRAINT FK02_empresa_x_usuario FOREIGN KEY (id_empresa) REFERENCES empresas (id_empresa);
ALTER TABLE usuario DROP CONSTRAINT IF EXISTS FK03_cargo_x_usuario;
ALTER TABLE usuario ADD CONSTRAINT FK03_cargo_x_usuario FOREIGN KEY (id_cargo) REFERENCES cargos (id_cargo);
ALTER TABLE usuario DROP CONSTRAINT IF EXISTS FK04_users_legado_x_usuario;
ALTER TABLE usuario ADD CONSTRAINT FK04_users_legado_x_usuario FOREIGN KEY (id_user_legado) REFERENCES users (id_user) ON DELETE SET NULL;
CREATE UNIQUE INDEX IF NOT EXISTS UX02_usuario_user_legado ON usuario (id_user_legado) WHERE id_user_legado IS NOT NULL;

-- Controle de chaves: quem retirou, liberou e recebeu passa a ser um usuário. As colunas antigas ficam para o histórico.
ALTER TABLE requisicoes_chaves ADD COLUMN IF NOT EXISTS id_usuario_retirada BIGINT NULL;
ALTER TABLE requisicoes_chaves ADD COLUMN IF NOT EXISTS id_usuario_liberacao BIGINT NULL;
ALTER TABLE requisicoes_chaves ADD COLUMN IF NOT EXISTS id_usuario_recebimento BIGINT NULL;
ALTER TABLE requisicoes_chaves ALTER COLUMN id_user_retirada DROP NOT NULL;
ALTER TABLE requisicoes_chaves ALTER COLUMN id_user_liberacao DROP NOT NULL;

ALTER TABLE requisicoes_chaves DROP CONSTRAINT IF EXISTS FK06_usuario_retirada_x_requisicoes_chaves;
ALTER TABLE requisicoes_chaves ADD CONSTRAINT FK06_usuario_retirada_x_requisicoes_chaves FOREIGN KEY (id_usuario_retirada) REFERENCES usuario (id_usuario);
ALTER TABLE requisicoes_chaves DROP CONSTRAINT IF EXISTS FK07_usuario_liberacao_x_requisicoes_chaves;
ALTER TABLE requisicoes_chaves ADD CONSTRAINT FK07_usuario_liberacao_x_requisicoes_chaves FOREIGN KEY (id_usuario_liberacao) REFERENCES usuario (id_usuario);
ALTER TABLE requisicoes_chaves DROP CONSTRAINT IF EXISTS FK08_usuario_recebimento_x_requisicoes_chaves;
ALTER TABLE requisicoes_chaves ADD CONSTRAINT FK08_usuario_recebimento_x_requisicoes_chaves FOREIGN KEY (id_usuario_recebimento) REFERENCES usuario (id_usuario);

-- Toda retirada precisa de quem retirou e quem liberou (antigo ou novo).
ALTER TABLE requisicoes_chaves DROP CONSTRAINT IF EXISTS CK03_requisicoes_chaves_pessoas;
ALTER TABLE requisicoes_chaves ADD CONSTRAINT CK03_requisicoes_chaves_pessoas CHECK (
    (id_user_retirada IS NOT NULL OR id_usuario_retirada IS NOT NULL)
    AND (id_user_liberacao IS NOT NULL OR id_usuario_liberacao IS NOT NULL)
);

-- Completa as retiradas de colaboradores já vinculados (reexecutável; sem vínculo nada muda).
UPDATE requisicoes_chaves rc SET id_usuario_retirada = u.id_usuario
FROM usuario u WHERE u.id_user_legado = rc.id_user_retirada AND rc.id_usuario_retirada IS NULL;
UPDATE requisicoes_chaves rc SET id_usuario_liberacao = u.id_usuario
FROM usuario u WHERE u.id_user_legado = rc.id_user_liberacao AND rc.id_usuario_liberacao IS NULL;
UPDATE requisicoes_chaves rc SET id_usuario_recebimento = u.id_usuario
FROM usuario u WHERE u.id_user_legado = rc.id_user_recebimento AND rc.id_usuario_recebimento IS NULL;
