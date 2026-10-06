# Migração da Caixinha (Lugia → NordTool)

Importa a aba **`Caixinha - Lançamentos`** da planilha do Lugia para `caixinha_responsavel` e `caixinha_lancamento`.

> Esta pasta **não** está no `filelist.txt` de propósito: a pipeline "SQL Dev" aplica DDL/DML automaticamente,
> e migração de dados é uma execução manual, feita uma vez por ambiente.

## Antes de começar
1. A DDL 24 (tabelas da Caixinha) já deve existir no banco de destino.
2. **Congele as edições no Lugia** e baixe a aba como **CSV (UTF-8)** (Google Sheets → Arquivo → Fazer download → CSV). Salve como `Caixinha - Lançamentos.csv` na pasta onde vai rodar o `psql`.
3. **Confira a ordem das colunas** (o `\copy` usa a posição, não o nome do cabeçalho):

   | Coluna | Conteúdo |
   |---|---|
   | A | data |
   | B | responsável |
   | C | lançado (`TRUE/FALSE`) |
   | D | pago (`TRUE/FALSE`) |
   | E | insumo |
   | F | valor |
   | G | id estável do Lugia (não é usado: a chave de reexecução é o nº da linha) |
   | H–J | vínculos dos PDFs no Drive (só carregados no staging, para dimensionar a decisão dos comprovantes) |

   Se a sua exportação parar na coluna G, remova `link_pdf_1..3` da lista de colunas em `02.carregar_csv_caixinha.sql`.
4. Faça um backup/snapshot do banco (ou rode primeiro no ambiente de desenvolvimento).

## Passo a passo (psql, dentro da pasta do CSV)
```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 01.staging_caixinha.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 02.carregar_csv_caixinha.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 03.transformar_caixinha.sql
psql "$DATABASE_URL" -f 04.conferencia_caixinha.sql
```
O passo 4 usa a tabela de staging; rode-o antes de apagá-la (o passo 1 a recria vazia).

## O que o passo 3 faz
- Ignora **linhas totalmente vazias**. Linhas com dados mas sem data válida, responsável, insumo ou valor positivo **abortam tudo** com a lista das linhas da planilha com problema (corrija no CSV e rode de novo).
- Cria os **responsáveis** distintos (sem diferenciar caixa; os já existentes são mantidos).
- `lancado`/`pago` → boolean (`TRUE/true/sim/x`); data ISO (`2026-10-01…`) ou `dd/MM/yyyy` → `date`; valor com ponto decimal (também aceita `R$ 1.234,56`).
- Remove o **apóstrofo inicial** (`'=`, `'+`, `'-`, `'@`) do insumo e do responsável.
- Guarda o **nº da linha da planilha** em `cd_legado`. Os lançamentos migrados não têm `cd_requisicao` nem comprovantes.
- Roda numa transação única.

## Reexecução
É seguro rodar o passo 3 de novo: lançamentos já importados são ignorados pelo `cd_legado` (nenhuma duplicação) e o que foi editado no NordTool depois não é alterado. Atenção: o `cd_legado` é a posição da linha — **não reordene nem apague linhas na planilha** entre uma execução e outra.

## Conferência (passo 4)
Compara CSV × banco (diferença deve ser **0**): nº de lançamentos, total, total pago, total a pagar, quantidade e total **por responsável** e apóstrofos residuais (deve ser 0). Compare também com os cartões do Lugia. A última consulta informa quantos lançamentos têm PDF no Drive.

## Comprovantes antigos (PDFs no Drive) — DECISÃO PENDENTE
Os PDFs **não migram sozinhos**. Opções (decidir com o Nicolas; ainda não decidido):

- **(a)** Baixar os PDFs do Drive e anexar manualmente pela tela da Caixinha.
- **(b)** Script que leia os links (colunas H–J, já carregadas em `stg_caixinha_lancamento`) e envie pela API (`POST /caixinha/lancamentos/{id}/comprovantes`) — precisa dos arquivos baixados localmente.
- **(c)** Manter os PDFs só no Drive e guardar o link como texto (exigiria uma coluna `tx_link_legado` em `caixinha_comprovante`).

Registre a escolha aqui quando for tomada: **decisão:** _(pendente)_

Depois de conferir, apague o staging se quiser: `DROP TABLE stg_caixinha_lancamento;`
