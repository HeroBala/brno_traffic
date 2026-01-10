BEGIN;

-- =========================================================
-- 1. FACT SCHEMA
-- =========================================================
CREATE SCHEMA IF NOT EXISTS fact;

-- =========================================================
-- 2. FACT: TRAFFIC ACCIDENT
-- Grain: 1 row = 1 accident
-- =========================================================
DROP TABLE IF EXISTS fact.fact_traffic_accident CASCADE;

CREATE TABLE fact.fact_traffic_accident (
    accident_fact_key   BIGSERIAL PRIMARY KEY,

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
    _fact_loaded_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Helpful indexes
CREATE INDEX idx_fact_accident_date
    ON fact.fact_traffic_accident(date_key);

CREATE INDEX idx_fact_accident_location
    ON fact.fact_traffic_accident(location_key);

CREATE INDEX idx_fact_accident_vehicle
    ON fact.fact_traffic_accident(vehicle_key);

-- =========================================================
-- 3. FACT: WEATHER HOURLY
-- Grain: 1 row = 1 hour
-- =========================================================
DROP TABLE IF EXISTS fact.fact_weather_hourly CASCADE;

CREATE TABLE fact.fact_weather_hourly (
    weather_fact_key    BIGSERIAL PRIMARY KEY,

    -- Foreign keys
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
    _fact_loaded_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Grain protection
    CONSTRAINT uq_fact_weather_hourly
        UNIQUE (date_key, time_key)
);

-- Helpful indexes
CREATE INDEX idx_fact_weather_date
    ON fact.fact_weather_hourly(date_key);

-- =========================================================
-- 4. FACT: VEHICLE TRAFFIC INTENSITY
-- Grain: 1 row = location × year
-- =========================================================
DROP TABLE IF EXISTS fact.fact_vehicle_traffic_intensity CASCADE;

CREATE TABLE fact.fact_vehicle_traffic_intensity (
    traffic_fact_key    BIGSERIAL PRIMARY KEY,

    -- Foreign keys
    location_key        INT NOT NULL
                            REFERENCES dim.dim_location(location_key),

    -- Time attribute (year-level grain)
    year                INT NOT NULL,

    -- Measures
    car_count           INT,
    truck_count         INT,

    -- Audit
    _fact_loaded_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Grain protection
    CONSTRAINT uq_fact_vehicle_traffic
        UNIQUE (location_key, year)
);

-- Helpful indexes
CREATE INDEX idx_fact_traffic_location
    ON fact.fact_vehicle_traffic_intensity(location_key);

COMMIT;

