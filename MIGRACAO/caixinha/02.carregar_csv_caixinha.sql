-- Migração da Caixinha - PASSO 2: carrega o CSV (UTF-8, com cabeçalho) na tabela de staging.
-- Rodar com psql na pasta onde está o CSV. Ajuste o nome do arquivo se necessário.
-- \copy é um meta-comando do psql: não funciona em outros clientes.
-- O CSV deve ter as 10 colunas A-J. Se a sua exportação parar na coluna G, remova link_pdf_1..3 da lista abaixo.

\copy stg_caixinha_lancamento (data, responsavel, lancado, pago, insumo, valor, id_estavel, link_pdf_1, link_pdf_2, link_pdf_3) FROM 'Caixinha - Lançamentos.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
