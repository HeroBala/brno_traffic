BEGIN;

-- =========================================================
-- STEP 0: Detect REAL SCD changes (event-time aware)
-- =========================================================
DROP TABLE IF EXISTS tmp_scd_location_changes;

CREATE TEMP TABLE tmp_scd_location_changes AS
SELECT
    s.municipality_code,
    s.cadastral_area,
    s.city_district,
    MIN(s.accident_date) AS change_date
FROM core.traffic_accident_clean s
JOIN dim.dim_location d
  ON d.municipality_code = s.municipality_code
 AND d.cadastral_area    = s.cadastral_area
WHERE d.is_current = TRUE
  AND s.city_district IS DISTINCT FROM d.city_district
GROUP BY
    s.municipality_code,
    s.cadastral_area,
    s.city_district;

-- =========================================================
-- STEP 1: Close old current rows (USE EVENT DATE)
-- =========================================================
UPDATE dim.dim_location d
SET valid_to   = c.change_date - 1,
    is_current = FALSE
FROM tmp_scd_location_changes c
WHERE d.municipality_code = c.municipality_code
  AND d.cadastral_area    = c.cadastral_area
  AND d.is_current        = TRUE;

-- =========================================================
-- STEP 2: Insert new current versions
-- =========================================================
INSERT INTO dim.dim_location (
    municipality_code,
    cadastral_area,
    city_district,
    valid_from,
    valid_to,
    is_current
)
SELECT
    c.municipality_code,
    c.cadastral_area,
    c.city_district,
    c.change_date,
    DATE '9999-12-31',
    TRUE
FROM tmp_scd_location_changes c
WHERE NOT EXISTS (
    SELECT 1
    FROM dim.dim_location d
    WHERE d.municipality_code = c.municipality_code
      AND d.cadastral_area    = c.cadastral_area
      AND d.city_district     = c.city_district
      AND d.is_current        = TRUE
);

COMMIT;

