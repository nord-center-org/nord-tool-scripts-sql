-- Ponto de extensão da hierarquia de acessos: '*' = todos os módulos; depois 'ENTREGA', 'CASAMENTO', ...
CREATE TABLE IF NOT EXISTS perfil_permissao (
    id_perfil BIGINT NOT NULL REFERENCES perfil (id_perfil) ON DELETE CASCADE,
    cd_modulo VARCHAR(40) NOT NULL,
    cd_acao VARCHAR(20) NOT NULL DEFAULT 'ESCRITA',
    PRIMARY KEY (id_perfil, cd_modulo)
);
