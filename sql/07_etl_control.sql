BEGIN;

-- =========================================================
-- ETL CONTROL SCHEMA
-- =========================================================
CREATE SCHEMA IF NOT EXISTS etl;

-- =========================================================
-- ETL CONTROL TABLE
-- Tracks incremental progress per process
-- =========================================================
CREATE TABLE IF NOT EXISTS etl.etl_control (
    process_name        TEXT PRIMARY KEY,
    last_processed_at   TIMESTAMP NOT NULL
);

-- =========================================================
-- INITIAL WATERMARKS
-- (safe to re-run)
-- =========================================================
INSERT INTO etl.etl_control (process_name, last_processed_at)
VALUES
    ('load_dimensions', '1900-01-01'),
    ('load_facts',      '1900-01-01'),
    ('scd_location',    '1900-01-01')
ON CONFLICT (process_name) DO NOTHING;

COMMIT;

