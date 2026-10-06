-- Configuração do módulo Casamento: chaves 'casal' e 'dataCasamento' (yyyy-MM-dd).
CREATE TABLE IF NOT EXISTS casamento_configuracao (
    cd_chave VARCHAR(50) PRIMARY KEY,
    vl_valor VARCHAR(255) NOT NULL,
    tx_descricao VARCHAR(255)
);
