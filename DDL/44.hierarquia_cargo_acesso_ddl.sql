-- Hierarquia: quem está abaixo de quem (o superior direto de cada usuário).
ALTER TABLE usuario ADD COLUMN IF NOT EXISTS id_superior BIGINT NULL;
ALTER TABLE usuario DROP CONSTRAINT IF EXISTS FK06_superior_x_usuario;
ALTER TABLE usuario ADD CONSTRAINT FK06_superior_x_usuario FOREIGN KEY (id_superior) REFERENCES usuario (id_usuario) ON DELETE SET NULL;
ALTER TABLE usuario DROP CONSTRAINT IF EXISTS CK02_usuario_superior_diferente;
ALTER TABLE usuario ADD CONSTRAINT CK02_usuario_superior_diferente CHECK (id_superior IS NULL OR id_superior <> id_usuario);
CREATE INDEX IF NOT EXISTS IX02_usuario_superior ON usuario (id_superior);

-- Acessos mínimos por cargo (residente, produção, estagiário, encarregado...): valem para todo usuário do cargo.
-- Resolução no backend, do mais específico para o menos: usuário+módulo, cargo+módulo, perfil+módulo, usuário+'*', perfil+'*'.
-- cd_acao: LEITURA, ESCRITA ou ADMIN (validado pelo enum Acao do backend).
CREATE TABLE IF NOT EXISTS cargo_permissao (
    id_cargo INTEGER NOT NULL,
    cd_modulo VARCHAR(40) NOT NULL,
    cd_acao VARCHAR(20) NOT NULL,
    CONSTRAINT PK_cargo_permissao PRIMARY KEY (id_cargo, cd_modulo),
    CONSTRAINT FK01_cargo_x_cargo_permissao FOREIGN KEY (id_cargo) REFERENCES cargos (id_cargo) ON DELETE CASCADE
);
