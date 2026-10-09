# Migração do Financeiro (planilha "End mounth" → NordTool)

Importa o histórico de meses da planilha de fechamento para `financeiro_lancamento` e `financeiro_mes`, para o NordTool já calcular médias, projeções e saldos em cima do que existia.

> Esta pasta **não** está no `filelist.txt` de propósito: a pipeline "SQL Dev" aplica DDL/DML automaticamente,
> e migração de dados é uma execução manual, feita uma vez por ambiente.

## Antes de começar
1. As DDL 25–31 e o DML 05 (Financeiro) já devem existir no banco de destino, com as pessoas **Nick, Thaina e Casal** e as categorias da planilha.
2. Monte o CSV (UTF-8, **com cabeçalho**) no formato **longo, uma linha por lançamento**, e salve como `financeiro_historico.csv` na pasta onde vai rodar o `psql`. Há um exemplo em `financeiro_historico.modelo.csv`.

   | Coluna | Conteúdo |
   |---|---|
   | A `mes` | mês do lançamento: `2026-03` ou `03/2026` |
   | B `tipo` | `Entrada` ou `Saída` |
   | C `categoria` | nome **igual** ao de uma categoria do NordTool (Salário, Vale, Fatura, Apartamento, Evolução de obra, Investimentos…) |
   | D `pessoa` | `Nick`, `Thaina` ou `Casal` (vazio vira `Casal`) |
   | E `descricao` | opcional |
   | F `valor` | sempre positivo (a saída também); aceita `1234.56` ou `R$ 1.234,56` |
   | G `data` | opcional (`dd/MM/yyyy` ou `yyyy-MM-dd`), dentro do mês; sem data vale o dia 1 |
   | H `saldo_final` | opcional: o **Saldo final do mês na planilha** (em qualquer linha daquele mês). Usado como saldo final do mês fechado e na conferência |
   | I `saldo_anterior` | opcional: o saldo anterior **daquele mês** quando não é o saldo final do mês anterior (no 1º mês, o saldo com que a planilha começou; `0` zera) |
   | J `realizado` | opcional: vazio = já recebido/pago; `não` ou `previsto` deixa como previsto (para o mês que ainda vai ser conferido) |

   - A linha **"Saldo anterior"** da planilha pode vir com a categoria `Saldo anterior`: ela **não vira lançamento** (o NordTool calcula o saldo anterior), só vira o saldo inicial daquele mês. Se a planilha não carregou o saldo do mês anterior (ex.: julho começou do zero), use isso para o NordTool reproduzir a planilha.
   - Se a planilha tem uma categoria que o NordTool não tem, **crie** em *Financeiro → Extrato → Pessoas e categorias* antes (ou corrija o nome no CSV).
3. Faça um backup/snapshot do banco (ou rode primeiro no ambiente de desenvolvimento).

## Passo a passo (psql, dentro da pasta do CSV)
```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 01.staging_financeiro.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 02.carregar_csv_financeiro.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 03.transformar_financeiro.sql
psql "$DATABASE_URL" -f 04.conferencia_financeiro.sql
```
O passo 4 usa a tabela de staging; rode-o antes de apagá-la (o passo 1 a recria vazia).

## O que o passo 3 faz
- Ignora **linhas totalmente vazias**. Linhas com problema (mês/tipo/categoria/pessoa inexistente, valor não positivo, data fora do mês, descrição longa) **abortam tudo** com a lista das linhas — corrija o CSV e rode de novo.
- Grava os lançamentos como **já realizados** (histórico; `realizado = não` deixa previsto), com o nº da linha do CSV em `cd_legado`. Não têm `cd_requisicao`.
- Meses **anteriores ao mês passado** entram **fechados**, com o saldo final da planilha (ou o calculado, se a planilha não informou). O **mês passado fica aberto** (é ele que você confere e fecha no mês seguinte), assim como o corrente e os futuros. O saldo inicial é gravado no primeiro mês e onde a planilha informou o saldo anterior.
- Roda numa transação única.

## Reexecução
É seguro rodar o passo 3 de novo: lançamentos já importados são ignorados pelo `cd_legado` e meses que já existem não são alterados. Atenção: o `cd_legado` é a posição da linha — **não reordene nem apague linhas do CSV** entre uma execução e outra.
Para corrigir um mês já importado, edite pelo próprio NordTool (reabrindo o mês, se estiver fechado).

## Conferência (passo 4)
Compara CSV × banco (diferença deve ser **0**): nº de lançamentos, total de entradas e de saídas, **mês a mês** (entradas, saídas e saldo final da planilha × banco) e o total por pessoa. Se `dif_saldo` não for 0, o saldo final da planilha não bate com as linhas do CSV — veja se falta algum lançamento.

Depois de conferir, apague o staging se quiser: `DROP TABLE stg_financeiro_lancamento;`
