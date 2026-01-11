BEGIN;

-- =========================================================
-- STEP 0: MATERIALIZE CHANGED LOCATIONS
-- =========================================================
DROP TABLE IF EXISTS tmp_scd_location_changes;

CREATE TEMP TABLE tmp_scd_location_changes AS
SELECT DISTINCT
    s.municipality_code,
    s.cadastral_area,
    s.city_district
FROM core.traffic_accident_clean s
JOIN dim.dim_location d
  ON d.municipality_code = s.municipality_code
 AND d.cadastral_area    = s.cadastral_area
WHERE d.is_current = TRUE
  AND d.city_district IS DISTINCT FROM s.city_district;

-- =========================================================
-- STEP 1: CLOSE EXISTING CURRENT ROWS
-- =========================================================
UPDATE dim.dim_location d
SET valid_to   = CURRENT_DATE - 1,
    is_current = FALSE
FROM tmp_scd_location_changes c
WHERE d.municipality_code = c.municipality_code
  AND d.cadastral_area    = c.cadastral_area
  AND d.is_current        = TRUE;

-- =========================================================
-- STEP 2: INSERT NEW CURRENT VERSIONS
-- =========================================================
INSERT INTO dim.dim_location (
    municipality_code,
    city_district,
    cadastral_area,
    valid_from,
    valid_to,
    is_current
)
SELECT
    c.municipality_code,
    c.city_district,
    c.cadastral_area,
    CURRENT_DATE,
    DATE '9999-12-31',
    TRUE
FROM tmp_scd_location_changes c;

COMMIT;

