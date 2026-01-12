#!/usr/bin/env bash

DB=brno
OUT=bi_export

mkdir -p "$OUT"

echo "Exporting BI schema objects..."

psql -d "$DB" -Atc "
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'bi'
ORDER BY table_name;
" | while read t; do
  echo "  bi.$t"
  psql -d "$DB" -c "\copy (SELECT * FROM bi.\"$t\") TO '$OUT/bi_$t.csv' WITH (FORMAT csv, HEADER true)"
done

echo "DONE ✅"

