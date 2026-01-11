BEGIN;

-- =====================================================
-- SCHEMA
-- =====================================================
CREATE SCHEMA IF NOT EXISTS staging;

-- =====================================================
-- VEHICLE TRAFFIC INTENSITY
-- =====================================================
CREATE TABLE IF NOT EXISTS staging.stg_vehicle_traffic_intensity (
    id                  INTEGER,

    car_2010            INTEGER,
    truc_2010           INTEGER,
    car_2011            INTEGER,
    truc_2011           INTEGER,
    car_2012            INTEGER,
    truc_2012           INTEGER,
    car_2013            INTEGER,
    truc_2013           INTEGER,
    car_2014            INTEGER,
    truc_2014           INTEGER,
    car_2015            INTEGER,
    truc_2015           INTEGER,
    car_2016            INTEGER,
    truc_2016           INTEGER,
    car_2017            INTEGER,
    truc_2017           INTEGER,
    car_2018            INTEGER,
    truc_2018           INTEGER,
    car_2019            INTEGER,
    truc_2019           INTEGER,
    car_2020            INTEGER,
    truc_2020           INTEGER,
    car_2021            INTEGER,
    truc_2021           INTEGER,
    car_2022            INTEGER,
    truc_2022           INTEGER,
    car_2023            INTEGER,
    truc_2023           INTEGER,

    datum_exportu       DATE,
    objectid            INTEGER,
    shape__length       DOUBLE PRECISION,
    globalid            UUID,

    -- technical column for incremental loading
    _loaded_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_stg_vehicle_loaded_at
    ON staging.stg_vehicle_traffic_intensity (_loaded_at);

-- =====================================================
-- WEATHER (HOURLY)
-- =====================================================
CREATE TABLE IF NOT EXISTS staging.stg_weather_hourly (
    time                    TIMESTAMP,

    temperature_2m          DOUBLE PRECISION,
    relativehumidity_2m     INTEGER,
    dewpoint_2m             DOUBLE PRECISION,
    apparent_temperature    DOUBLE PRECISION,
    precipitation           DOUBLE PRECISION,
    rain                    DOUBLE PRECISION,
    snowfall                DOUBLE PRECISION,
    snow_depth              DOUBLE PRECISION,
    weathercode             INTEGER,
    windspeed_10m           DOUBLE PRECISION,
    cloudcover              INTEGER,
    pressure_msl            DOUBLE PRECISION,

    _loaded_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_stg_weather_loaded_at
    ON staging.stg_weather_hourly (_loaded_at);

CREATE INDEX IF NOT EXISTS idx_weather_time
    ON staging.stg_weather_hourly (time);

-- =====================================================
-- TRAFFIC ACCIDENTS
-- =====================================================
CREATE TABLE IF NOT EXISTS staging.stg_traffic_accident (
    object_id               INTEGER,

    municipality_code       TEXT,
    alcohol_offender        TEXT,
    main_cause              TEXT,
    collision_type          TEXT,
    consequences            TEXT,
    cause                   TEXT,
    road_condition          TEXT,
    weather_conditions      TEXT,
    visibility_range        TEXT,
    accident_location       TEXT,
    road_type               TEXT,
    vehicle_type            TEXT,
    city_district           TEXT,
    gender                  TEXT,
    alcohol                 TEXT,
    day_of_week             TEXT,
    month_text              TEXT,
    cadastral_area          TEXT,
    result                  TEXT,
    person_role             TEXT,
    fault                   TEXT,
    lighting_conditions     TEXT,
    road_situation          TEXT,
    person                  TEXT,
    driver_condition        TEXT,
    time_period             TEXT,

    local_code              INTEGER,
    target_fid              INTEGER,
    join_count              INTEGER,
    object_id_1             INTEGER,
    join_count_1            INTEGER,
    target_fid_1            INTEGER,

    day                     INTEGER,
    age                     TEXT,
    death_days              TEXT,
    birth_year              TEXT,

    police_code_p48a        TEXT,
    police_code_p59d        TEXT,

    year                    INTEGER,
    event_type              INTEGER,
    death_flag              INTEGER,
    lightly_injured         INTEGER,
    seriously_injured       INTEGER,
    killed_persons          INTEGER,

    vehicle_id              TEXT,
    hour                    TEXT,
    driver_influence        TEXT,

    time                    INTEGER,
    month                   INTEGER,
    accident_id             BIGINT,
    date                    DATE,

    material_damage         INTEGER,
    vehicle_damage          INTEGER,

    global_id               UUID,

    _loaded_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_accident_loaded_at
    ON staging.stg_traffic_accident (_loaded_at);

CREATE INDEX IF NOT EXISTS idx_accident_date
    ON staging.stg_traffic_accident (date);

CREATE INDEX IF NOT EXISTS idx_accident_year
    ON staging.stg_traffic_accident (year);

CREATE INDEX IF NOT EXISTS idx_accident_municipality
    ON staging.stg_traffic_accident (municipality_code);

COMMIT;

