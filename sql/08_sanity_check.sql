-- =========================================================
-- DATA WAREHOUSE SANITY CHECKS
-- =========================================================

-- =========================================================
-- 1. SCHEMA EXISTENCE
-- =========================================================
SELECT 'schema_dim_exists'  AS check, EXISTS (
    SELECT 1 FROM information_schema.schemata WHERE schema_name = 'dim'
) AS result
UNION ALL
SELECT 'schema_fact_exists', EXISTS (
    SELECT 1 FROM information_schema.schemata WHERE schema_name = 'fact'
);

-- =========================================================
-- 2. DIMENSION TABLE ROW COUNTS (MUST BE > 0)
-- =========================================================
SELECT 'dim_date_empty'        AS check, COUNT(*) = 0 AS failed FROM dim.dim_date
UNION ALL
SELECT 'dim_time_empty',       COUNT(*) = 0 FROM dim.dim_time
UNION ALL
SELECT 'dim_location_empty',   COUNT(*) = 0 FROM dim.dim_location
UNION ALL
SELECT 'dim_weather_empty',    COUNT(*) = 0 FROM dim.dim_weather
UNION ALL
SELECT 'dim_vehicle_empty',    COUNT(*) = 0 FROM dim.dim_vehicle
UNION ALL
SELECT 'dim_person_empty',     COUNT(*) = 0 FROM dim.dim_person;

-- =========================================================
-- 3. FACT TABLE ROW COUNTS (MUST BE > 0)
-- =========================================================
SELECT 'fact_traffic_accident_empty' AS check, COUNT(*) = 0 AS failed
FROM fact.fact_traffic_accident
UNION ALL
SELECT 'fact_weather_hourly_empty', COUNT(*) = 0
FROM fact.fact_weather_hourly
UNION ALL
SELECT 'fact_vehicle_traffic_empty', COUNT(*) = 0
FROM fact.fact_vehicle_traffic_intensity;

-- =========================================================
-- 4. MANDATORY FK INTEGRITY (MUST BE ZERO)
-- =========================================================
SELECT 'accident_missing_date' AS check, COUNT(*) AS failed
FROM fact.fact_traffic_accident
WHERE date_key IS NULL
UNION ALL
SELECT 'weather_missing_date', COUNT(*)
FROM fact.fact_weather_hourly
WHERE date_key IS NULL
UNION ALL
SELECT 'weather_missing_time', COUNT(*)
FROM fact.fact_weather_hourly
WHERE time_key IS NULL
UNION ALL
SELECT 'weather_missing_weather', COUNT(*)
FROM fact.fact_weather_hourly
WHERE weather_key IS NULL;

-- =========================================================
-- 5. ORPHAN FK DETECTION (CRITICAL)
-- =========================================================
SELECT 'orphan_accident_date' AS check, COUNT(*) AS failed
FROM fact.fact_traffic_accident f
LEFT JOIN dim.dim_date d ON d.date_key = f.date_key
WHERE d.date_key IS NULL

UNION ALL
SELECT 'orphan_weather_weather', COUNT(*)
FROM fact.fact_weather_hourly f
LEFT JOIN dim.dim_weather w ON w.weather_key = f.weather_key
WHERE w.weather_key IS NULL

UNION ALL
SELECT 'orphan_traffic_location', COUNT(*)
FROM fact.fact_vehicle_traffic_intensity f
LEFT JOIN dim.dim_location l ON l.location_key = f.location_key
WHERE l.location_key IS NULL;

-- =========================================================
-- 6. GRAIN VIOLATIONS (MUST RETURN ZERO ROWS)
-- =========================================================
SELECT 'weather_grain_violation' AS check, COUNT(*) AS failed
FROM (
    SELECT date_key, time_key, COUNT(*)
    FROM fact.fact_weather_hourly
    GROUP BY date_key, time_key
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'traffic_intensity_grain_violation', COUNT(*)
FROM (
    SELECT location_key, year, COUNT(*)
    FROM fact.fact_vehicle_traffic_intensity
    GROUP BY location_key, year
    HAVING COUNT(*) > 1
) y;

-- =========================================================
-- 7. BUSINESS RULE SANITY
-- =========================================================
SELECT 'negative_injuries' AS check, COUNT(*) AS failed
FROM fact.fact_traffic_accident
WHERE lightly_injured < 0
   OR seriously_injured < 0
   OR killed_persons < 0

UNION ALL
SELECT 'negative_vehicle_counts', COUNT(*)
FROM fact.fact_vehicle_traffic_intensity
WHERE car_count < 0 OR truck_count < 0

UNION ALL
SELECT 'implausible_temperature', COUNT(*)
FROM fact.fact_weather_hourly
WHERE temperature_2m < -50 OR temperature_2m > 60;

-- =========================================================
-- 8. CORE VS FACT PARITY CHECKS
-- =========================================================
SELECT
    'accident_count_mismatch' AS check,
    ABS(
        (SELECT COUNT(*) FROM core.traffic_accident_clean) -
        (SELECT COUNT(*) FROM fact.fact_traffic_accident)
    ) AS difference;

-- =========================================================
-- 9. DATE COVERAGE CONSISTENCY
-- =========================================================
SELECT 'fact_date_outside_dim_range' AS check, COUNT(*) AS failed
FROM fact.fact_traffic_accident f
JOIN dim.dim_date d ON d.date_key = f.date_key
WHERE d.full_date < (SELECT MIN(full_date) FROM dim.dim_date)
   OR d.full_date > (SELECT MAX(full_date) FROM dim.dim_date);

-- =========================================================
-- 10. NULL HOTSPOT ANALYSIS (DIAGNOSTIC)
-- =========================================================
SELECT
    COUNT(*) FILTER (WHERE location_key IS NULL) AS null_location,
    COUNT(*) FILTER (WHERE vehicle_key IS NULL)  AS null_vehicle,
    COUNT(*) FILTER (WHERE person_key IS NULL)   AS null_person
FROM fact.fact_traffic_accident;

