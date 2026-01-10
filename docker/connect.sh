#!/bin/bash
set -e

echo "🛑 Stopping existing containers..."
docker compose down

echo "🧹 Removing old Postgres volume (if exists)..."
docker volume rm brno_traffic_pg_data 2>/dev/null || true

echo "🚀 Starting Postgres fresh..."
docker compose up -d

echo "⏳ Waiting for Postgres to be ready..."
until docker exec brno_traffic_postgres pg_isready -U hero -d brno_traffic >/dev/null 2>&1; do
  sleep 1
done

echo "✅ Postgres is ready!"

echo "🔗 Connecting to database..."
docker exec -it brno_traffic_postgres psql -U hero -d brno_traffic

