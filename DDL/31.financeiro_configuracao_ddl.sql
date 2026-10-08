-- Financeiro: parâmetros do módulo (um único registro, cd_configuracao = 'PADRAO').
-- vl_meta_saldo: saldo mínimo desejado ao fim do mês (o "verde" do dashboard).
-- nr_meses_media: quantos meses anteriores entram na média das projeções.
-- nr_dia_conferencia: dia do mês em que os valores reais costumam ser conferidos (lembrete).
CREATE TABLE IF NOT EXISTS financeiro_configuracao (
    id_configuracao BIGSERIAL NOT NULL,
    cd_configuracao VARCHAR(30) NOT NULL,
    vl_meta_saldo DECIMAL(15, 2) NOT NULL DEFAULT 0,
    nr_meses_media INTEGER NOT NULL DEFAULT 3,
    nr_dia_conferencia INTEGER NOT NULL DEFAULT 8,
    dh_alteracao TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_financeiro_configuracao PRIMARY KEY (id_configuracao),
    CONSTRAINT UK01_financeiro_configuracao UNIQUE (cd_configuracao)
);
