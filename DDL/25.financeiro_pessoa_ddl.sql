-- Financeiro (Gestão Individual): de quem é cada lançamento (Nick, Thaina e "Casal").
-- Não é o autor do lançamento (esse é o usuário logado); id_usuario liga a pessoa ao login, quando houver.
CREATE TABLE IF NOT EXISTS financeiro_pessoa (
    id_pessoa BIGSERIAL NOT NULL,
    nm_pessoa VARCHAR(100) NOT NULL,
    in_compartilhado BOOLEAN NOT NULL DEFAULT FALSE,
    id_usuario BIGINT NULL,
    nr_ordem INTEGER NOT NULL DEFAULT 0,
    in_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    dh_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_financeiro_pessoa PRIMARY KEY (id_pessoa),
    CONSTRAINT UK01_financeiro_pessoa UNIQUE (nm_pessoa),
    CONSTRAINT UK02_financeiro_pessoa UNIQUE (id_usuario),
    CONSTRAINT FK01_usuario_x_financeiro_pessoa FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);
