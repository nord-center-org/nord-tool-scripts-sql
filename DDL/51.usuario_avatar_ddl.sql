-- Avatar de cada usuário (criador de avatar): a configuração é um JSON pequeno montado pelo frontend
-- (pele, cabelo, olhos, roupa da função na obra, capacete, acessório, fundo). Sem linha = avatar padrão.
CREATE TABLE IF NOT EXISTS usuario_avatar (
    id_usuario BIGINT NOT NULL,
    ds_config VARCHAR(2000) NOT NULL,
    dh_alteracao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_usuario_avatar PRIMARY KEY (id_usuario),
    CONSTRAINT FK01_usuario_x_usuario_avatar FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE
);
