-- Migração da Caixinha (Lugia -> NordTool) - PASSO 1: tabela de staging.
-- Rodar com psql. Esta pasta NÃO faz parte do filelist.txt: a pipeline não executa migração de dados.
-- Todas as colunas são TEXT: o CSV entra "como veio" e a conversão acontece no passo 3.
-- Aba "Caixinha - Lançamentos": A data · B responsável · C lançado · D pago · E insumo · F valor · G id estável ·
-- H-J vínculos dos PDFs no Drive (não migram sozinhos; ficam aqui só para dimensionar a decisão dos comprovantes).

DROP TABLE IF EXISTS stg_caixinha_lancamento;

CREATE TABLE stg_caixinha_lancamento (
    -- posição da linha dentro do CSV (1 = primeira linha de dados); o nº da linha na planilha é ordem + 1
    ordem BIGSERIAL,
    data TEXT, responsavel TEXT, lancado TEXT, pago TEXT, insumo TEXT, valor TEXT,
    id_estavel TEXT, link_pdf_1 TEXT, link_pdf_2 TEXT, link_pdf_3 TEXT
);
