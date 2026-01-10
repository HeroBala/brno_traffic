-- =====================================================
-- 1. LIST ALL SCHEMAS
-- =====================================================
\dn

-- =====================================================
-- 2. LIST ALL TABLES (WITH SCHEMA)
-- =====================================================
\dt *.*

-- =====================================================
-- 3. SHOW COLUMNS FOR CORE TABLES
-- =====================================================
SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'core'
ORDER BY table_name, ordinal_position;

-- =====================================================
-- 4. SHOW COLUMNS FOR DIM TABLES
-- =====================================================
SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'dim'
ORDER BY table_name, ordinal_position;

-- =====================================================
-- 5. SHOW COLUMNS FOR FACT TABLES
-- =====================================================
SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'fact'
ORDER BY table_name, ordinal_position;

-- =====================================================
-- 6. SHOW FOREIGN KEYS (IMPORTANT)
-- =====================================================
SELECT
    tc.table_schema,
    tc.table_name,
    kcu.column_name,
    ccu.table_schema AS ref_schema,
    ccu.table_name   AS ref_table,
    ccu.column_name  AS ref_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_schema, tc.table_name;

-- =====================================================
-- 7. SAMPLE DATA (LIMITED)
-- =====================================================
SELECT * FROM core.traffic_accident_clean LIMIT 5;
SELECT * FROM core.weather_hourly_clean LIMIT 5;
SELECT * FROM core.vehicle_traffic_intensity_clean LIMIT 5;

