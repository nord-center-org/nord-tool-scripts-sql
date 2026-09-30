#!/bin/bash

set -e

echo "🚀 Iniciando PostgreSQL..."

docker-entrypoint.sh postgres &

POSTGRES_PID=$!

echo "⏳ Aguardando PostgreSQL ficar disponível..."

until pg_isready -U "${POSTGRES_USER:-postgres}" >/dev/null 2>&1; do
    sleep 1
done

echo "✅ PostgreSQL está disponível"

echo "🚀 Iniciando execução dos scripts SQL"

if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "❌ DATABASE_URL não está definida"
    kill "$POSTGRES_PID"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "📦 Criando schema nord_tool..."

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<-EOSQL
    CREATE SCHEMA IF NOT EXISTS nord_tool;
EOSQL

while IFS= read -r file || [[ -n "$file" ]]; do

    [[ -z "$file" || "$file" =~ ^# ]] && continue

    echo "➡️ Executando: $file"

    psql "$DATABASE_URL" \
        -v ON_ERROR_STOP=1 \
        -f "$SCRIPT_DIR/$file"

done < "$SCRIPT_DIR/filelist.txt"

echo "✅ Scripts executados com sucesso"

echo "🟢 PostgreSQL continuará em execução"

wait "$POSTGRES_PID"