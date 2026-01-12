#!/usr/bin/env bash

DB=brno
OUT=bi

mkdir -p "$OUT"

echo "Exporting DIM tables..."
psql -d "$DB" -Atc "SELECT tablename FROM pg_tables WHERE schemaname='dim'" |
while read t; do
  echo "  dim.$t"
  psql -d "$DB" -c "\copy dim.$t TO '$OUT/dim_$t.csv' WITH (FORMAT csv, HEADER true)"
done

echo "Exporting FACT tables..."
psql -d "$DB" -Atc "SELECT tablename FROM pg_tables WHERE schemaname='fact'" |
while read t; do
  echo "  fact.$t"
  psql -d "$DB" -c "\copy fact.$t TO '$OUT/fact_$t.csv' WITH (FORMAT csv, HEADER true)"
done

echo "DONE"

