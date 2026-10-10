-- Permissões do perfil por módulo. cd_modulo: código do módulo (enum Modulo do backend) ou '*' para todos.
-- cd_acao: NENHUM, LEITURA, ESCRITA ou ADMIN (hierárquico; validado pelo enum Acao do backend). Exceções por usuário em usuario_permissao.
CREATE TABLE IF NOT EXISTS perfil_permissao (
    id_perfil BIGINT NOT NULL REFERENCES perfil (id_perfil) ON DELETE CASCADE,
    cd_modulo VARCHAR(40) NOT NULL,
    cd_acao VARCHAR(20) NOT NULL DEFAULT 'ESCRITA',
    PRIMARY KEY (id_perfil, cd_modulo)
);
