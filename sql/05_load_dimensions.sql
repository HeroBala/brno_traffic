BEGIN;

-- =========================================================
-- DATE DIMENSION  (SINGLE INSERT, UNION ALL SOURCES)
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
SELECT DISTINCT
    TO_CHAR(d, 'YYYYMMDD')::INT        AS date_key,
    d                                 AS full_date,
    EXTRACT(DAY FROM d)::INT           AS day,
    EXTRACT(MONTH FROM d)::INT         AS month,
    EXTRACT(YEAR FROM d)::INT          AS year,
    TRIM(TO_CHAR(d, 'Day'))            AS day_of_week,
    TRIM(TO_CHAR(d, 'Month'))          AS month_name,
    EXTRACT(ISODOW FROM d) IN (6,7)    AS is_weekend
FROM (
    SELECT accident_date AS d
    FROM core.traffic_accident_clean
    WHERE accident_date IS NOT NULL

    UNION

    SELECT weather_time::DATE AS d
    FROM core.weather_hourly_clean
    WHERE weather_time IS NOT NULL
) dates
ON CONFLICT (date_key) DO NOTHING;

-- =========================================================
-- TIME DIMENSION
-- =========================================================
INSERT INTO dim.dim_time (
    time_key,
    hour,
    minute,
    time_label
)
SELECT DISTINCT
    time_hhmm                                   AS time_key,
    time_hhmm / 100                             AS hour,
    time_hhmm % 100                             AS minute,
    LPAD((time_hhmm / 100)::TEXT,2,'0') || ':' ||
    LPAD((time_hhmm % 100)::TEXT,2,'0')
FROM core.traffic_accident_clean
WHERE time_hhmm IS NOT NULL
  AND dq_invalid_time = 0
ON CONFLICT (time_key) DO NOTHING;

INSERT INTO dim.dim_time (
    time_key,
    hour,
    minute,
    time_label
)
SELECT DISTINCT
    EXTRACT(HOUR FROM weather_time)::INT * 100 +
    EXTRACT(MINUTE FROM weather_time)::INT,
    EXTRACT(HOUR FROM weather_time)::INT,
    EXTRACT(MINUTE FROM weather_time)::INT,
    TO_CHAR(weather_time, 'HH24:MI')
FROM core.weather_hourly_clean
WHERE weather_time IS NOT NULL
ON CONFLICT (time_key) DO NOTHING;

-- =========================================================
-- LOCATION DIMENSION
-- =========================================================
INSERT INTO dim.dim_location (
    municipality_code,
    city_district,
    cadastral_area
)
SELECT DISTINCT
    municipality_code,
    city_district,
    cadastral_area
FROM core.traffic_accident_clean
WHERE municipality_code IS NOT NULL
ON CONFLICT (municipality_code, city_district, cadastral_area) DO NOTHING;

-- =========================================================
-- WEATHER DIMENSION
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
-- VEHICLE DIMENSION
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
-- PERSON DIMENSION
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

