-- Migração do casamento (Lugia -> NordTool) - PASSO 1: tabelas de staging.
-- Rodar com psql. Esta pasta NÃO faz parte do filelist.txt: a pipeline não executa migração de dados.
-- Todas as colunas são TEXT: o CSV entra "como veio" e a conversão acontece no passo 3.
-- A ORDEM das colunas deve ser a da planilha (o \copy ignora os nomes do cabeçalho; ver README).

DROP TABLE IF EXISTS stg_casamento_fornecedor;
DROP TABLE IF EXISTS stg_casamento_convidado;
DROP TABLE IF EXISTS stg_casamento_marco;
DROP TABLE IF EXISTS stg_casamento_config;

CREATE TABLE stg_casamento_fornecedor (
    ordem BIGSERIAL,
    id TEXT, name TEXT, category TEXT, contact TEXT, status TEXT, value TEXT, notes TEXT
);

CREATE TABLE stg_casamento_convidado (
    ordem BIGSERIAL,
    id TEXT, name TEXT, grp TEXT, phone TEXT, relation TEXT, status TEXT
);

CREATE TABLE stg_casamento_marco (
    ordem BIGSERIAL,
    id TEXT, title TEXT, description TEXT, due_date TEXT, completed TEXT
);

-- Aba Configurações: uma linha por chave (couple, weddingDate).
CREATE TABLE stg_casamento_config (
    chave TEXT, valor TEXT
);
