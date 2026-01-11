-- =====================================================
-- TEST INCREMENTAL LOADING — FIRST RUN (+1)
-- =====================================================

-- Clean temp table if re-run in same session
DROP TABLE IF EXISTS tmp_fact_count_before;

-- -----------------------------------------
-- 1. COUNT BEFORE
-- -----------------------------------------
SELECT COUNT(*) AS before_count
INTO TEMP TABLE tmp_fact_count_before
FROM fact.fact_traffic_accident;

-- -----------------------------------------
-- 2. INSERT ONE NEW RAW ROW
-- -----------------------------------------
INSERT INTO staging.stg_traffic_accident (
    accident_id,
    date,
    municipality_code,
    cadastral_area,
    city_district
)
VALUES (
    99999999,
    CURRENT_DATE,
    'BRNO_TEST',
    'CENTER',
    'TEST_DISTRICT'
);

-- -----------------------------------------
-- 3. LOAD DIMENSIONS (ENSURE KEYS)
-- -----------------------------------------
\i sql/05_load_dimensions.sql
\i sql/05b_scd_location.sql

-- -----------------------------------------
-- 4. REFRESH CORE (VIEWS)
-- -----------------------------------------
\i sql/03_core_cleaning.sql

-- -----------------------------------------
-- 5. RUN INCREMENTAL FACT LOAD
-- -----------------------------------------
\i sql/08_load_facts.sql

-- -----------------------------------------
-- 6. PROOF (+1)
-- -----------------------------------------
SELECT
    (SELECT before_count FROM tmp_fact_count_before) AS before_count,
    COUNT(*) AS after_count,
    COUNT(*) - (SELECT before_count FROM tmp_fact_count_before) AS rows_inserted
FROM fact.fact_traffic_accident;

