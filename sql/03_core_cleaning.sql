BEGIN;

-- =========================================================
-- 1. CORE SCHEMA
-- =========================================================
CREATE SCHEMA IF NOT EXISTS core;

-- =========================================================
-- 2. DROP EXISTING CORE TABLES (IDEMPOTENT)
-- =========================================================
DROP TABLE IF EXISTS core.vehicle_traffic_intensity_clean;
DROP TABLE IF EXISTS core.weather_hourly_clean;
DROP TABLE IF EXISTS core.traffic_accident_clean;

-- =========================================================
-- 3. VEHICLE TRAFFIC INTENSITY — CLEAN
-- =========================================================
CREATE TABLE core.vehicle_traffic_intensity_clean AS
SELECT
    id,

    car_2010, truc_2010,
    car_2011, truc_2011,
    car_2012, truc_2012,
    car_2013, truc_2013,
    car_2014, truc_2014,
    car_2015, truc_2015,
    car_2016, truc_2016,
    car_2017, truc_2017,
    car_2018, truc_2018,
    car_2019, truc_2019,
    car_2020, truc_2020,
    car_2021, truc_2021,
    car_2022, truc_2022,
    car_2023, truc_2023,

    datum_exportu::DATE      AS export_date,
    objectid                AS object_id,
    shape__length            AS shape_length,
    globalid::UUID           AS global_id,

    CURRENT_TIMESTAMP        AS _core_loaded_at
FROM staging.stg_vehicle_traffic_intensity;

-- =========================================================
-- 4. WEATHER HOURLY — CLEAN
-- =========================================================
CREATE TABLE core.weather_hourly_clean AS
SELECT
    time::TIMESTAMP          AS weather_time,

    temperature_2m,
    relativehumidity_2m,
    dewpoint_2m,
    apparent_temperature,
    precipitation,
    rain,
    snowfall,
    snow_depth,
    weathercode,
    windspeed_10m,
    cloudcover,
    pressure_msl,

    CURRENT_TIMESTAMP        AS _core_loaded_at
FROM staging.stg_weather_hourly;

-- =========================================================
-- 5. TRAFFIC ACCIDENT — CORE CLEANING
-- =========================================================
CREATE TABLE core.traffic_accident_clean AS
SELECT
    object_id,

    municipality_code,
    city_district,
    cadastral_area,

    accident_id,
    date::DATE AS accident_date,

    -- ---------- SAFE NUMERIC CASTS ----------
    CASE
        WHEN age ~ '^[0-9]+(\.0)?$'
        THEN FLOOR(age::NUMERIC)::INT
    END AS age,

    CASE
        WHEN birth_year ~ '^[0-9]+(\.0)?$'
        THEN FLOOR(birth_year::NUMERIC)::INT
    END AS birth_year,

    CASE
        WHEN death_days ~ '^[0-9]+(\.0)?$'
        THEN FLOOR(death_days::NUMERIC)::INT
    END AS death_days,

    -- ---------- TIME VALIDATION (HHMM) ----------
    CASE
        WHEN time BETWEEN 0 AND 2359 AND (time % 100) < 60
        THEN time
    END AS time_hhmm,

    CASE
        WHEN NOT (time BETWEEN 0 AND 2359 AND (time % 100) < 60)
        THEN 1 ELSE 0
    END AS dq_invalid_time,

    hour::TEXT               AS hour_raw,
    day,
    month,
    year,

    day_of_week,
    month_text,
    time_period,

    accident_location,
    road_type,
    road_condition,
    road_situation,
    visibility_range,
    lighting_conditions,
    weather_conditions,

    main_cause,
    cause,
    collision_type,
    consequences,

    vehicle_type,

    CASE
        WHEN vehicle_id ~ '^[0-9]+(\.0)?$'
        THEN FLOOR(vehicle_id::NUMERIC)::INT
    END AS vehicle_id,

    person,
    person_role,
    gender,

    alcohol,
    alcohol_offender,
    driver_condition,

    CASE
        WHEN driver_influence ~ '^[0-9]+(\.0)?$'
        THEN FLOOR(driver_influence::NUMERIC)::INT
    END AS driver_influence,

    fault,

    event_type,
    death_flag,
    lightly_injured,
    seriously_injured,
    killed_persons,

    material_damage,
    vehicle_damage,

    local_code,
    police_code_p48a,
    police_code_p59d,

    global_id::UUID,

    CURRENT_TIMESTAMP AS _core_loaded_at
FROM staging.stg_traffic_accident;

-- =========================================================
-- 6. INDEXES (PERFORMANCE + DW READY)
-- =========================================================
CREATE INDEX IF NOT EXISTS idx_core_weather_time
    ON core.weather_hourly_clean(weather_time);

CREATE INDEX IF NOT EXISTS idx_core_accident_date
    ON core.traffic_accident_clean(accident_date);

CREATE INDEX IF NOT EXISTS idx_core_accident_time
    ON core.traffic_accident_clean(time_hhmm);

COMMIT;
