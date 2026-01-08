#!/bin/bash

# =====================================================
# CONFIGURATION
# =====================================================
PROJECT_NAME="brno_traffic"
SERVICE_NAME="postgres"
CONTAINER_NAME="brno_traffic_postgres"
DEFAULT_DB="brno_traffic"
DB_USER="hero"

# =====================================================
# ENVIRONMENT CHECKS
# =====================================================
require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is not installed."
    exit 1
  fi
}

require_docker_running() {
  if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is not running."
    exit 1
  fi
}

# =====================================================
# CONTAINER STATUS
# =====================================================
container_running() {
  docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"
}

container_exists() {
  docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"
}

db_status() {
  if container_running; then
    echo "RUNNING"
  elif container_exists; then
    echo "STOPPED"
  else
    echo "NOT CREATED"
  fi
}

# =====================================================
# CORE ACTIONS
# =====================================================
start_db() {
  echo "Starting PostgreSQL..."
  docker compose up -d
  sleep 2
}

ensure_running() {
  if ! container_running; then
    start_db
  fi
}

pause() {
  read -r -p "Press ENTER to continue..."
}

# =====================================================
# DATABASE HELPERS
# =====================================================
list_databases() {
  docker compose exec -T $SERVICE_NAME psql -U $DB_USER -d postgres \
    -tAc "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;"
}

database_exists() {
  docker compose exec -T $SERVICE_NAME psql -U $DB_USER -d postgres \
    -tAc "SELECT 1 FROM pg_database WHERE datname='$1';" | grep -q 1
}

create_database() {
  docker compose exec -T $SERVICE_NAME psql -U $DB_USER -d postgres \
    -c "CREATE DATABASE \"$1\";"
}

drop_database() {
  docker compose exec -T $SERVICE_NAME psql -U $DB_USER -d postgres \
    -c "DROP DATABASE \"$1\";"
}

# =====================================================
# DATABASE INSPECTION
# =====================================================
list_schemas() {
  docker compose exec $SERVICE_NAME psql -U $DB_USER -d "$1" -c "\dn"
}

list_tables() {
  docker compose exec $SERVICE_NAME psql -U $DB_USER -d "$1" -c "\dt $2.*"
}

describe_table() {
  docker compose exec $SERVICE_NAME psql -U $DB_USER -d "$1" -c "\d $2.$3"
}

db_size() {
  docker compose exec -T $SERVICE_NAME psql -U $DB_USER -d postgres \
    -c "SELECT pg_size_pretty(pg_database_size('$1')) AS size;"
}

# =====================================================
# CONNECTION
# =====================================================
connect_db() {
  ensure_running
  docker compose exec $SERVICE_NAME psql -U $DB_USER -d "$1"
}

# =====================================================
# UI
# =====================================================
render_header() {
  clear
  echo "==============================================="
  echo " BRNO TRAFFIC – DATABASE MANAGEMENT TOOL"
  echo "==============================================="
  echo "PostgreSQL status : $(db_status)"
  echo "Default database  : ${DEFAULT_DB}"
  echo ""
  echo "Tip: Press ENTER to quick-connect to default database"
  echo ""
}

menu() {
  echo "1) Start PostgreSQL"
  echo "2) Quick connect to default DB"
  echo "3) List databases"
  echo "4) Create database"
  echo "5) Drop database (DANGEROUS)"
  echo "6) Connect to database"
  echo "7) Inspect database (schemas/tables)"
  echo "8) Database size"
  echo "q) Quit"
  echo ""

  read -r -p "Select option (ENTER = quick connect, q = quit): " INPUT

  # Quick connect
  if [[ -z "$INPUT" ]]; then
    connect_db "$DEFAULT_DB"
    return
  fi

  case "$INPUT" in
    1)
      start_db
      pause
      ;;
    2)
      connect_db "$DEFAULT_DB"
      ;;
    3)
      ensure_running
      list_databases
      pause
      ;;
    4)
      ensure_running
      read -r -p "Enter new database name: " DB
      if database_exists "$DB"; then
        echo "Database already exists."
      else
        create_database "$DB"
        echo "Database '$DB' created."
      fi
      pause
      ;;
    5)
      ensure_running
      read -r -p "Enter database name to DROP: " DB
      read -r -p "Type DROP to confirm: " CONFIRM
      if [[ "$CONFIRM" == "DROP" ]]; then
        drop_database "$DB"
        echo "Database '$DB' dropped."
      else
        echo "Cancelled."
      fi
      pause
      ;;
    6)
      ensure_running
      read -r -p "Enter database name: " DB
      connect_db "$DB"
      ;;
    7)
      ensure_running
      read -r -p "Database name: " DB
      list_schemas "$DB"
      read -r -p "Schema name: " SC
      list_tables "$DB" "$SC"
      read -r -p "Table to describe (ENTER to skip): " TB
      if [[ -n "$TB" ]]; then
        describe_table "$DB" "$SC" "$TB"
      fi
      pause
      ;;
    8)
      ensure_running
      read -r -p "Database name: " DB
      db_size "$DB"
      pause
      ;;
    q|Q)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option."
      pause
      ;;
  esac
}

# =====================================================
# ENTRY POINT
# =====================================================
require_docker
require_docker_running

while true; do
  render_header
  menu
done

