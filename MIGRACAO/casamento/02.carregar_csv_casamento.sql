-- Migração do casamento - PASSO 2: carrega os CSVs (UTF-8, com cabeçalho) nas tabelas de staging.
-- Rodar com psql na pasta onde estão os CSVs. Ajuste os nomes dos arquivos se necessário.
-- \copy é um meta-comando do psql: não funciona em outros clientes.

\copy stg_casamento_fornecedor (id, name, category, contact, status, value, notes) FROM 'Wedding Day - Fornecedores.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy stg_casamento_convidado (id, name, grp, phone, relation, status) FROM 'Wedding Day - Convidados.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy stg_casamento_marco (id, title, description, due_date, completed) FROM 'Wedding Day - Marcos.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy stg_casamento_config (chave, valor) FROM 'Wedding Day - Configurações.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
