#!/bin/bash

set -e

echo "🚀 Iniciando execução dos scripts SQL"

if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "❌ DATABASE_URL não está definida"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

POSTGRES_PID=""

# Railway / container PostgreSQL
if command -v docker-entrypoint.sh >/dev/null 2>&1; then

    echo "🐘 Ambiente PostgreSQL detectado"

    echo "🚀 Iniciando PostgreSQL..."

    docker-entrypoint.sh postgres &

    POSTGRES_PID=$!

    echo "⏳ Aguardando PostgreSQL ficar disponível..."

    until pg_isready -U "${POSTGRES_USER:-postgres}" >/dev/null 2>&1; do
        sleep 1
    done

    echo "✅ PostgreSQL está disponível"

else

    echo "🌐 Ambiente externo detectado"
    echo "🔗 Usando DATABASE_URL fornecida pelo ambiente"

fi

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

# Somente a Railway precisa manter o PostgreSQL vivo.
if [[ -n "$POSTGRES_PID" ]]; then

    echo "🟢 PostgreSQL continuará em execução"

    wait "$POSTGRES_PID"

fi