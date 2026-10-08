-- Financeiro: dados iniciais (reexecutável). Nick e Thaina ficam sem login até serem vinculados no sistema.
INSERT INTO financeiro_pessoa (nm_pessoa, in_compartilhado, nr_ordem)
VALUES
    ('Nick', FALSE, 1),
    ('Thaina', FALSE, 2),
    ('Casal', TRUE, 3)
ON CONFLICT (nm_pessoa) DO NOTHING;

-- Categorias da planilha de fechamento do mês.
-- Salário cai no 5º dia útil e o vale no dia 20; o saldo anterior é calculado (não é digitado).
INSERT INTO financeiro_categoria (nm_categoria, cd_tipo, cd_projecao, in_fixa, cd_regra_data, nr_dia, nr_ordem)
VALUES
    ('Salário', 'ENTRADA', 'FIXA_MEDIA', TRUE, 'DIA_UTIL', 5, 1),
    ('Vale', 'ENTRADA', 'FIXA_MEDIA', TRUE, 'DIA_MES', 20, 2),
    ('Saldo anterior', 'ENTRADA', 'SALDO_ANTERIOR', TRUE, NULL, NULL, 3),
    ('Outras entradas', 'ENTRADA', 'MANUAL', FALSE, NULL, NULL, 4),
    ('Fatura', 'SAIDA', 'RITMO_FATURA', TRUE, NULL, NULL, 1),
    ('Apartamento', 'SAIDA', 'FIXA_VALOR', TRUE, NULL, NULL, 2),
    ('Evolução de obra', 'SAIDA', 'FIXA_VALOR', TRUE, NULL, NULL, 3),
    ('Investimentos', 'SAIDA', 'FIXA_VALOR', TRUE, NULL, NULL, 4),
    ('Assinaturas', 'SAIDA', 'VARIAVEL_MEDIA', FALSE, NULL, NULL, 5),
    ('Conta de luz', 'SAIDA', 'VARIAVEL_MEDIA', FALSE, NULL, NULL, 6),
    ('Juan', 'SAIDA', 'VARIAVEL_MEDIA', FALSE, NULL, NULL, 7),
    ('Outras saídas', 'SAIDA', 'VARIAVEL_MEDIA', FALSE, NULL, NULL, 8)
ON CONFLICT (nm_categoria, cd_tipo) DO NOTHING;

INSERT INTO financeiro_configuracao (cd_configuracao)
VALUES ('PADRAO')
ON CONFLICT (cd_configuracao) DO NOTHING;
