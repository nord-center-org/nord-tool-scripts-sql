CREATE TABLE IF NOT EXISTS requisicoes_chaves (
    id_requisicao SERIAL NOT NULL,
    cd_retirada VARCHAR(20) NOT NULL,
    dt_retirada TIMESTAMP NOT NULL,
    dt_recebimento TIMESTAMP NULL,
    id_apartamento_vistoria BIGINT NOT NULL,
    id_user_retirada INTEGER NOT NULL,
    id_user_liberacao INTEGER NOT NULL,
    id_user_recebimento INTEGER NULL,
    nm_status_requisicao VARCHAR(20) NOT NULL DEFAULT 'ABERTO',
    CONSTRAINT PK_requisicoes_chaves PRIMARY KEY (id_requisicao),
    CONSTRAINT UK01_requisicoes_chaves_cd_retirada UNIQUE (cd_retirada),
    CONSTRAINT FK01_apartamento_vistoria_x_requisicoes_chaves FOREIGN KEY (id_apartamento_vistoria) REFERENCES apartamento_vistoria (id_apartamento_vistoria),
    CONSTRAINT FK02_user_retirada_x_requisicoes_chaves FOREIGN KEY (id_user_retirada) REFERENCES users (id_user),
    CONSTRAINT FK03_user_liberacao_x_requisicoes_chaves FOREIGN KEY (id_user_liberacao) REFERENCES users (id_user),
    CONSTRAINT FK04_user_recebimento_x_requisicoes_chaves FOREIGN KEY (id_user_recebimento) REFERENCES users (id_user)
);