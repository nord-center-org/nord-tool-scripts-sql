-- Migração do Financeiro - PASSO 2: carrega o CSV (UTF-8, com cabeçalho) na tabela de staging.
-- Rodar com psql na pasta onde está o CSV. Ajuste o nome do arquivo se necessário.
-- \copy é um meta-comando do psql: não funciona em outros clientes. O CSV deve ter as 9 colunas A-I.

\copy stg_financeiro_lancamento (mes, tipo, categoria, pessoa, descricao, valor, data, saldo_final, saldo_anterior) FROM 'financeiro_historico.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
