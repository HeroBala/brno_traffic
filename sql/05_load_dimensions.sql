BEGIN;

-- =========================================================
-- DATE DIMENSION (INCREMENTAL, SAFE)
-- =========================================================
INSERT INTO dim.dim_date (
    date_key,
    full_date,
    day,
    month,
    year,
    day_of_week,
    month_name,
    is_weekend
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT,
    d,
    EXTRACT(DAY FROM d)::INT,
    EXTRACT(MONTH FROM d)::INT,
    EXTRACT(YEAR FROM d)::INT,
    TRIM(TO_CHAR(d, 'Day')),
    TRIM(TO_CHAR(d, 'Month')),
    EXTRACT(ISODOW FROM d) IN (6,7)
FROM (
    SELECT DISTINCT accident_date AS d
    FROM core.traffic_accident_clean
    WHERE accident_date IS NOT NULL

    UNION

    SELECT DISTINCT weather_time::DATE
    FROM core.weather_hourly_clean
    WHERE weather_time IS NOT NULL
) dates
ON CONFLICT (date_key) DO NOTHING;

-- =========================================================
-- TIME DIMENSION (INCREMENTAL, SAFE)
-- =========================================================
INSERT INTO dim.dim_time (
    time_key,
    hour,
    minute,
    time_label
)
SELECT
    time_hhmm,
    time_hhmm / 100,
    time_hhmm % 100,
    LPAD((time_hhmm / 100)::TEXT, 2, '0') || ':' ||
    LPAD((time_hhmm % 100)::TEXT, 2, '0')
FROM (
    SELECT DISTINCT time_hhmm
    FROM core.traffic_accident_clean
    WHERE time_hhmm IS NOT NULL
      AND dq_invalid_time = 0
) t
ON CONFLICT (time_key) DO NOTHING;

INSERT INTO dim.dim_time (
    time_key,
    hour,
    minute,
    time_label
)
SELECT
    EXTRACT(HOUR FROM weather_time)::INT * 100 +
    EXTRACT(MINUTE FROM weather_time)::INT,
    EXTRACT(HOUR FROM weather_time)::INT,
    EXTRACT(MINUTE FROM weather_time)::INT,
    TO_CHAR(weather_time, 'HH24:MI')
FROM (
    SELECT DISTINCT weather_time
    FROM core.weather_hourly_clean
    WHERE weather_time IS NOT NULL
) w
ON CONFLICT (time_key) DO NOTHING;

-- =========================================================
-- LOCATION DIMENSION (SCD TYPE 2 — SAFE & INCREMENTAL)
-- =========================================================

-- close existing current records if new combination appears
UPDATE dim.dim_location d
SET valid_to = CURRENT_DATE - 1,
    is_current = FALSE
FROM (
    SELECT DISTINCT
        municipality_code,
        city_district,
        cadastral_area
    FROM core.traffic_accident_clean
    WHERE municipality_code IS NOT NULL
) s
WHERE d.municipality_code = s.municipality_code
  AND d.cadastral_area = s.cadastral_area
  AND d.is_current = TRUE
  AND (
        d.city_district IS DISTINCT FROM s.city_district
      );

-- insert new current versions
INSERT INTO dim.dim_location (
    municipality_code,
    city_district,
    cadastral_area,
    valid_from,
    valid_to,
    is_current
)
SELECT
    s.municipality_code,
    s.city_district,
    s.cadastral_area,
    CURRENT_DATE,
    DATE '9999-12-31',
    TRUE
FROM (
    SELECT DISTINCT
        municipality_code,
        city_district,
        cadastral_area
    FROM core.traffic_accident_clean
    WHERE municipality_code IS NOT NULL
) s
LEFT JOIN dim.dim_location d
  ON d.municipality_code = s.municipality_code
 AND d.cadastral_area = s.cadastral_area
 AND d.is_current = TRUE
WHERE d.location_key IS NULL;

-- =========================================================
-- WEATHER DIMENSION (INCREMENTAL)
-- =========================================================
INSERT INTO dim.dim_weather (
    weathercode,
    cloudcover,
    pressure_msl
)
SELECT DISTINCT
    weathercode,
    cloudcover,
    pressure_msl
FROM core.weather_hourly_clean
WHERE weathercode IS NOT NULL
ON CONFLICT (weathercode, cloudcover, pressure_msl) DO NOTHING;

-- =========================================================
-- VEHICLE DIMENSION (INCREMENTAL)
-- =========================================================
INSERT INTO dim.dim_vehicle (
    vehicle_type,
    vehicle_id
)
SELECT DISTINCT
    vehicle_type,
    vehicle_id
FROM core.traffic_accident_clean
WHERE vehicle_id IS NOT NULL
ON CONFLICT (vehicle_type, vehicle_id) DO NOTHING;

-- =========================================================
-- PERSON DIMENSION (INCREMENTAL)
-- =========================================================
INSERT INTO dim.dim_person (
    gender,
    person_role,
    age,
    birth_year
)
SELECT DISTINCT
    gender,
    person_role,
    age,
    birth_year
FROM core.traffic_accident_clean
WHERE person_role IS NOT NULL
ON CONFLICT (gender, person_role, age, birth_year) DO NOTHING;

COMMIT;

