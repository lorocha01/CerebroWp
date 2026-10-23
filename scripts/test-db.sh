#!/usr/bin/env bash
# Aplica as migrations num banco Postgres descartável e roda os testes SQL.
#
# Uso: PGHOST=... PGPORT=... PGUSER=postgres scripts/test-db.sh
# Cada arquivo tests/db/test_*.sql roda numa transação desfeita no final.
set -euo pipefail

raiz="$(cd "$(dirname "$0")/.." && pwd)"
banco="cerebro_teste_$$"

psql -X -q -v ON_ERROR_STOP=1 -d postgres -c "create database $banco" >/dev/null
trap 'psql -X -q -d postgres -c "drop database if exists $banco" >/dev/null' EXIT

rodar() { psql -X -q -v ON_ERROR_STOP=1 -d "$banco" "$@"; }

rodar -f "$raiz/tests/db/00_ambiente_supabase.sql" >/dev/null
for m in "$raiz"/supabase/migrations/*.sql; do
  rodar -1 -f "$m" >/dev/null
done
echo "migrations aplicadas: $(ls "$raiz"/supabase/migrations/*.sql | wc -l)"

falhas=0
for t in "$raiz"/tests/db/test_*.sql; do
  if out=$( { echo 'begin;'; cat "$t"; echo 'rollback;'; } | rodar 2>&1 ); then
    echo "ok    $(basename "$t")"
  else
    echo "FALHA $(basename "$t")"
    echo "$out" | grep -E 'ERROR|FALHOU' | sed 's/^/      /'
    falhas=$((falhas + 1))
  fi
done

[ "$falhas" -eq 0 ] || { echo "$falhas arquivo(s) com falha"; exit 1; }
echo "todos os testes passaram"
