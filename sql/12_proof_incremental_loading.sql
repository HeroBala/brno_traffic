-- CLEAN UP FROM PREVIOUS RUNS
DROP TABLE IF EXISTS tmp_fact_count_before;

-- ==========================================
-- STEP 1: FACT COUNT BEFORE
-- ==========================================
SELECT COUNT(*) AS before_count
INTO TEMP TABLE tmp_fact_count_before
FROM fact.fact_traffic_accident;

-- ==========================================
-- STEP 2: RUN CORE (VIEWS ONLY)
-- ==========================================
\i sql/03_core_cleaning.sql

-- ==========================================
-- STEP 3: RUN INCREMENTAL FACT LOAD
-- ==========================================
\i sql/08_load_facts.sql

-- ==========================================
-- STEP 4: SHOW RESULT
-- ==========================================
SELECT
    (SELECT before_count FROM tmp_fact_count_before) AS before_count,
    COUNT(*) AS after_count,
    COUNT(*) - (SELECT before_count FROM tmp_fact_count_before) AS rows_inserted
FROM fact.fact_traffic_accident;

