-- Exceções de permissão por usuário, sobre as do perfil (perfil_permissao).
-- Resolução no backend, do mais específico para o menos: usuário+módulo, perfil+módulo, usuário+'*', perfil+'*'.
-- cd_acao: NENHUM, LEITURA, ESCRITA ou ADMIN (hierárquico; validado pelo enum Acao do backend). NENHUM nega o módulo
-- mesmo quando o perfil concede.
CREATE TABLE IF NOT EXISTS usuario_permissao (
    id_usuario BIGINT NOT NULL,
    cd_modulo VARCHAR(40) NOT NULL,
    cd_acao VARCHAR(20) NOT NULL,
    CONSTRAINT PK_usuario_permissao PRIMARY KEY (id_usuario, cd_modulo),
    CONSTRAINT FK01_usuario_x_usuario_permissao FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE
);
