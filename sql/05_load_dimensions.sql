BEGIN;

-- =========================================================
-- 0. SAFETY: FIX LOCATION UNIQUE INDEX (OBJECT_ID-BASED)
-- =========================================================

DROP INDEX IF EXISTS dim.uq_dim_location_current;

CREATE UNIQUE INDEX IF NOT EXISTS uq_dim_location_current
ON dim.dim_location (object_id)
WHERE is_current = TRUE;

-- =========================================================
-- 1. UNKNOWN ROWS (STAR SCHEMA GUARANTEE)
-- =========================================================

-- TIME
INSERT INTO dim.dim_time (time_key, hour, minute, time_label)
VALUES (-1, 0, 0, 'UNKNOWN')
ON CONFLICT (time_key) DO NOTHING;

-- LOCATION
INSERT INTO dim.dim_location (
    location_key,
    object_id,
    municipality_code,
    city_district,
    cadastral_area,
    valid_from,
    valid_to,
    is_current
)
VALUES (
    -1,
    NULL,
    'UNKNOWN',
    'UNKNOWN',
    'UNKNOWN',
    CURRENT_DATE,
    DATE '9999-12-31',
    TRUE
)
ON CONFLICT DO NOTHING;

-- WEATHER
INSERT INTO dim.dim_weather (
    weather_key,
    weathercode,
    cloudcover,
    pressure_msl
)
VALUES (-1, NULL, NULL, NULL)
ON CONFLICT DO NOTHING;

-- VEHICLE
INSERT INTO dim.dim_vehicle (
    vehicle_key,
    vehicle_type,
    vehicle_id
)
VALUES (-1, 'UNKNOWN', -1)
ON CONFLICT DO NOTHING;

-- PERSON
INSERT INTO dim.dim_person (
    person_key,
    gender,
    person_role,
    age,
    birth_year
)
VALUES (-1, 'UNKNOWN', 'UNKNOWN', NULL, NULL)
ON CONFLICT DO NOTHING;

-- =========================================================
-- 2. DATE DIMENSION
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
    EXTRACT(DAY FROM d)::SMALLINT,
    EXTRACT(MONTH FROM d)::SMALLINT,
    EXTRACT(YEAR FROM d)::SMALLINT,
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
) src
ON CONFLICT (date_key) DO NOTHING;

-- =========================================================
-- 3. TIME DIMENSION
-- =========================================================

-- From accidents (valid only)
INSERT INTO dim.dim_time (
    time_key,
    hour,
    minute,
    time_label
)
SELECT DISTINCT
    time_hhmm,
    (time_hhmm / 100)::SMALLINT,
    (time_hhmm % 100)::SMALLINT,
    LPAD((time_hhmm / 100)::TEXT, 2, '0')
    || ':' ||
    LPAD((time_hhmm % 100)::TEXT, 2, '0')
FROM core.traffic_accident_clean
WHERE time_hhmm IS NOT NULL
  AND dq_invalid_time = 0
ON CONFLICT (time_key) DO NOTHING;

-- From weather
INSERT INTO dim.dim_time (
    time_key,
    hour,
    minute,
    time_label
)
SELECT DISTINCT
    EXTRACT(HOUR FROM weather_time)::INT * 100 +
    EXTRACT(MINUTE FROM weather_time)::INT,
    EXTRACT(HOUR FROM weather_time)::SMALLINT,
    EXTRACT(MINUTE FROM weather_time)::SMALLINT,
    TO_CHAR(weather_time, 'HH24:MI')
FROM core.weather_hourly_clean
WHERE weather_time IS NOT NULL
ON CONFLICT (time_key) DO NOTHING;

-- =========================================================
-- 4. LOCATION DIMENSION (CURRENT ONLY, OBJECT_ID KEY)
-- =========================================================

INSERT INTO dim.dim_location (
    object_id,
    municipality_code,
    city_district,
    cadastral_area,
    valid_from,
    valid_to,
    is_current
)
SELECT DISTINCT
    s.object_id,
    s.municipality_code,
    s.city_district,
    s.cadastral_area,
    CURRENT_DATE,
    DATE '9999-12-31',
    TRUE
FROM core.traffic_accident_clean s
WHERE s.object_id IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM dim.dim_location d
        WHERE d.object_id = s.object_id
          AND d.is_current = TRUE
  );

-- =========================================================
-- 5. WEATHER DIMENSION
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
-- 6. VEHICLE DIMENSION
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
-- 7. PERSON DIMENSION
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

