#!/bin/bash

set -e

echo "🚀 Iniciando execução dos scripts SQL"

if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "❌ DATABASE_URL não está definida"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<-EOSQL

    CREATE SCHEMA IF NOT EXISTS nord_tool;

EOSQL

while IFS= read -r file || [[ -n "$file" ]]; do

    [[ -z "$file" || "$file" =~ ^# ]] && continue

    echo "➡️ Executando: $file"

    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$SCRIPT_DIR/$file"

done < "$SCRIPT_DIR/filelist.txt"

echo "✅ Scripts executados com sucesso"
