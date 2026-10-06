# Migração do casamento (Lugia → NordTool)

Importa as abas **Fornecedores**, **Convidados**, **Marcos** e **Configurações** da planilha `Wedding Day` do Lugia
para as tabelas `casamento_*`. As abas Orçamento/Lançamentos **não** entram (ficam para o controle financeiro): só exporte e guarde.

> Esta pasta **não** está no `filelist.txt` de propósito: a pipeline "SQL Dev" aplica DDL/DML automaticamente,
> e migração de dados é uma execução manual, feita uma vez por ambiente.

## Antes de começar
1. As tabelas do casamento (DDL 18–22) já devem existir no banco de destino.
2. Baixe cada aba como **CSV (UTF-8)** (Google Sheets → Arquivo → Fazer download → CSV) e salve na mesma pasta, com estes nomes:
   - `Wedding Day - Fornecedores.csv`
   - `Wedding Day - Convidados.csv`
   - `Wedding Day - Marcos.csv`
   - `Wedding Day - Configurações.csv`
3. **Confira a ordem das colunas** (o `\copy` usa a posição, não o nome do cabeçalho):

   | CSV | Ordem esperada das colunas |
   |---|---|
   | Fornecedores | `id, name, category, contact, status, value, notes` |
   | Convidados | `id, name, group, phone, relation, status` |
   | Marcos | `id, title, description, dueDate, completed` |
   | Configurações | `chave, valor` (linhas `couple` e `weddingDate`) |

   Se a planilha tiver outra ordem, ajuste a lista de colunas em `02.carregar_csv_casamento.sql`.
4. Faça um backup/snapshot do banco (ou rode primeiro no ambiente de desenvolvimento).

## Passo a passo (psql, dentro da pasta dos CSVs)
```bash
psql "$DATABASE_URL" -f 01.staging_casamento.sql
psql "$DATABASE_URL" -f 02.carregar_csv_casamento.sql
psql "$DATABASE_URL" -f 03.transformar_casamento.sql
psql "$DATABASE_URL" -f 04.conferencia_casamento.sql
```
Os passos 3 e 4 usam as tabelas de staging; rode-os enquanto elas existirem (o passo 1 as recria vazias).

## O que o passo 3 faz
- Remove o **apóstrofo inicial** (`'=…`, `'+…`, `'-…`, `'@…`) de nomes, observações e descrições.
- `completed` → boolean (`TRUE/true/sim/x`); `dueDate` → `LEFT(…,10)` como data (também aceita `dd/MM/yyyy`).
- `value` → `NUMERIC` (ponto decimal; também aceita `R$ 1.234,56`).
- Status → códigos: `Pesquisando/Orçamento/Contratado` → `PESQUISANDO/ORCAMENTO/CONTRATADO`; `Não convidado/Convidado/Confirmado/Não irá` → `NAO_CONVIDADO/CONVIDADO/CONFIRMADO/NAO_IRA` (vazio vira o primeiro da lista).
- Guarda o id antigo em `cd_legado` (sem número no CSV, usa a posição da linha). Convidados entram com 0 acompanhantes e sem mesa.
- `couple` → `casal` e `weddingDate` → `dataCasamento` em `casamento_configuracao` **sem sobrescrever** o que já estiver configurado.
- Roda numa transação: status desconhecido ou nome/título vazio **aborta tudo** com uma mensagem apontando o problema.

## Reexecução
É seguro rodar o passo 3 de novo: registros já importados são ignorados pelo `cd_legado` (nenhuma duplicação), e o que foi editado no NordTool depois da migração não é alterado.

## Conferência (passo 4)
Cada linha traz `esperado` (CSV) × `migrado` (banco) e `diferenca` (deve ser **0**): fornecedores por status, soma dos valores contratados, convidados por status e por grupo, marcos (total e concluídos), apóstrofos residuais (deve ser 0) e a configuração. Compare também esses números com a tela do Lugia.

Depois de conferir, apague o staging se quiser: `DROP TABLE stg_casamento_fornecedor, stg_casamento_convidado, stg_casamento_marco, stg_casamento_config;`
