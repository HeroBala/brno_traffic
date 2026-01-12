-- =========================================================
-- DEMO: SCD TYPE 2 WITH HISTORY PRESERVATION
-- =========================================================

BEGIN;

-- ---------------------------------------------------------
-- STEP 0: CLEAN DEMO STATE (ONLY TEST KEY)
-- ---------------------------------------------------------
DELETE FROM dim.dim_location
WHERE municipality_code = 'BRNO_TEST'
  AND cadastral_area = 'CENTER';

DELETE FROM staging.stg_traffic_accident
WHERE municipality_code = 'BRNO_TEST'
  AND cadastral_area = 'CENTER';

COMMIT;

-- ---------------------------------------------------------
-- STEP 1: INSERT INITIAL (OLD) SOURCE DATA
-- ---------------------------------------------------------
INSERT INTO staging.stg_traffic_accident (
    accident_id,
    date,
    municipality_code,
    cadastral_area,
    city_district
)
VALUES (
    111111111,
    DATE '2026-01-12',
    'BRNO_TEST',
    'CENTER',
    'OLD_DISTRICT'
);

-- ---------------------------------------------------------
-- STEP 2: INITIAL DIMENSION LOAD (BASELINE)
-- ---------------------------------------------------------
\i sql/05_load_dimensions.sql

-- ---------------------------------------------------------
-- STEP 3: SHOW DIMENSION BEFORE CHANGE
-- ---------------------------------------------------------
SELECT
    'BEFORE CHANGE' AS stage,
    municipality_code,
    cadastral_area,
    city_district,
    valid_from,
    valid_to,
    is_current
FROM dim.dim_location
WHERE municipality_code = 'BRNO_TEST'
  AND cadastral_area = 'CENTER';

-- ---------------------------------------------------------
-- STEP 4: INSERT CHANGED SOURCE DATA (BUSINESS EVENT)
-- ---------------------------------------------------------
INSERT INTO staging.stg_traffic_accident (
    accident_id,
    date,
    municipality_code,
    cadastral_area,
    city_district
)
VALUES (
    222222222,
    DATE '2027-01-05',
    'BRNO_TEST',
    'CENTER',
    'NEW_DISTRICT_NAME'
);

-- ---------------------------------------------------------
-- STEP 5: RUN SCD TYPE 2 LOGIC
-- ---------------------------------------------------------
\i sql/05b_scd_location.sql

-- ---------------------------------------------------------
-- STEP 6: SHOW DIMENSION AFTER CHANGE (HISTORY PRESERVED)
-- ---------------------------------------------------------
SELECT
    'AFTER CHANGE' AS stage,
    municipality_code,
    cadastral_area,
    city_district,
    valid_from,
    valid_to,
    is_current
FROM dim.dim_location
WHERE municipality_code = 'BRNO_TEST'
  AND cadastral_area = 'CENTER'
ORDER BY valid_from;

-- ---------------------------------------------------------
-- STEP 7: EXPLICIT HISTORY PROOF (IMPORTANT)
-- ---------------------------------------------------------
SELECT
    municipality_code,
    cadastral_area,
    city_district,
    is_current
FROM dim.dim_location
WHERE municipality_code = 'BRNO_TEST'
  AND cadastral_area = 'CENTER'
  AND is_current = FALSE;

