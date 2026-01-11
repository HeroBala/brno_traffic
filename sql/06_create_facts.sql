BEGIN;

-- =========================================================
-- 1. FACT SCHEMA
-- =========================================================
CREATE SCHEMA IF NOT EXISTS fact;

-- =========================================================
-- 2. FACT: TRAFFIC ACCIDENT
-- Grain: 1 row = 1 accident
-- =========================================================
CREATE TABLE IF NOT EXISTS fact.fact_traffic_accident (
    accident_key        BIGSERIAL PRIMARY KEY,

    -- Foreign keys
    date_key            INT NOT NULL
        REFERENCES dim.dim_date(date_key),

    time_key            INT
        REFERENCES dim.dim_time(time_key),

    location_key        INT
        REFERENCES dim.dim_location(location_key),

    vehicle_key         INT
        REFERENCES dim.dim_vehicle(vehicle_key),

    person_key          INT
        REFERENCES dim.dim_person(person_key),

    -- Degenerate dimensions
    accident_id         BIGINT,
    object_id           INT,

    -- Measures
    lightly_injured     INT,
    seriously_injured   INT,
    killed_persons      INT,
    material_damage     INT,
    vehicle_damage      INT,

    -- Flags / data quality
    death_flag          INT,
    dq_invalid_time     INT,

    -- Audit
    _fact_loaded_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Grain protection
    CONSTRAINT uq_fact_accident UNIQUE (accident_id)
);

-- =========================================================
-- 3. FACT: WEATHER HOURLY
-- Grain: 1 row = 1 hour
-- =========================================================
CREATE TABLE IF NOT EXISTS fact.fact_weather_hourly (
    weather_fact_key    BIGSERIAL PRIMARY KEY,

    date_key            INT NOT NULL
        REFERENCES dim.dim_date(date_key),

    time_key            INT NOT NULL
        REFERENCES dim.dim_time(time_key),

    weather_key         INT NOT NULL
        REFERENCES dim.dim_weather(weather_key),

    -- Measures
    temperature_2m       DOUBLE PRECISION,
    dewpoint_2m          DOUBLE PRECISION,
    apparent_temperature DOUBLE PRECISION,
    precipitation        DOUBLE PRECISION,
    rain                 DOUBLE PRECISION,
    snowfall             DOUBLE PRECISION,
    snow_depth           DOUBLE PRECISION,
    windspeed_10m        DOUBLE PRECISION,

    -- Audit
    _fact_loaded_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Grain protection
    CONSTRAINT uq_weather_hour UNIQUE (date_key, time_key)
);

-- =========================================================
-- 4. FACT: VEHICLE TRAFFIC INTENSITY
-- Grain: location × year
-- =========================================================
CREATE TABLE IF NOT EXISTS fact.fact_vehicle_traffic_intensity (
    traffic_fact_key    BIGSERIAL PRIMARY KEY,

    location_key        INT NOT NULL
        REFERENCES dim.dim_location(location_key),

    year                INT NOT NULL,

    -- Measures
    car_count           INT,
    truck_count         INT,

    -- Audit
    _fact_loaded_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Grain protection
    CONSTRAINT uq_vehicle_intensity UNIQUE (location_key, year)
);

COMMIT;

