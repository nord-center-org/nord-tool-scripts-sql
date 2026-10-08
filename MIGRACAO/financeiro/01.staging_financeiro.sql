-- Migração do Financeiro (planilha "End mounth" -> NordTool) - PASSO 1: tabela de staging.
-- Rodar com psql. Esta pasta NÃO faz parte do filelist.txt: a pipeline não executa migração de dados.
-- Formato "longo", um lançamento por linha: A mês · B tipo · C categoria · D pessoa · E descrição · F valor · G data ·
-- H saldo final do mês na planilha · I saldo anterior (só no 1º mês). Todas as colunas são TEXT: o CSV entra "como veio".

DROP TABLE IF EXISTS stg_financeiro_lancamento;

CREATE TABLE stg_financeiro_lancamento (
    -- posição da linha dentro do CSV (1 = primeira linha de dados); o nº da linha na planilha é ordem + 1
    ordem BIGSERIAL,
    mes TEXT, tipo TEXT, categoria TEXT, pessoa TEXT, descricao TEXT, valor TEXT, data TEXT,
    saldo_final TEXT, saldo_anterior TEXT
);
