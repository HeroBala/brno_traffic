BEGIN;

-- =========================================================
-- DIMENSION SCHEMA
-- =========================================================
CREATE SCHEMA IF NOT EXISTS dim;

-- =========================================================
-- DATE DIMENSION
-- =========================================================
CREATE TABLE IF NOT EXISTS dim.dim_date (
    date_key        INT PRIMARY KEY,          -- YYYYMMDD
    full_date       DATE NOT NULL UNIQUE,
    day             SMALLINT NOT NULL,
    month           SMALLINT NOT NULL,
    year            SMALLINT NOT NULL,
    day_of_week     TEXT NOT NULL,
    month_name      TEXT NOT NULL,
    is_weekend      BOOLEAN NOT NULL
);

-- =========================================================
-- TIME DIMENSION
-- =========================================================
CREATE TABLE IF NOT EXISTS dim.dim_time (
    time_key        INT PRIMARY KEY,           -- HHMM
    hour            SMALLINT NOT NULL CHECK (hour BETWEEN 0 AND 23),
    minute          SMALLINT NOT NULL CHECK (minute BETWEEN 0 AND 59),
    time_label      TEXT NOT NULL
);

-- =========================================================
-- LOCATION DIMENSION (SCD TYPE 2)  ✅ FIXED
-- =========================================================
CREATE TABLE IF NOT EXISTS dim.dim_location (
    location_key        SERIAL PRIMARY KEY,

    -- ✅ SOURCE SYSTEM BUSINESS KEY (REQUIRED)
    object_id           INTEGER,

    municipality_code   TEXT NOT NULL,
    city_district       TEXT NOT NULL,
    cadastral_area      TEXT NOT NULL,

    valid_from          DATE NOT NULL,
    valid_to            DATE NOT NULL DEFAULT '9999-12-31',
    is_current          BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_dim_location_current
    ON dim.dim_location (municipality_code, cadastral_area)
    WHERE is_current = TRUE;

-- =========================================================
-- WEATHER DIMENSION
-- =========================================================
CREATE TABLE IF NOT EXISTS dim.dim_weather (
    weather_key     SERIAL PRIMARY KEY,
    weathercode     INT,
    cloudcover      SMALLINT CHECK (cloudcover BETWEEN 0 AND 100),
    pressure_msl    DOUBLE PRECISION
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_dim_weather
    ON dim.dim_weather (weathercode, cloudcover, pressure_msl);

-- =========================================================
-- VEHICLE DIMENSION
-- =========================================================
CREATE TABLE IF NOT EXISTS dim.dim_vehicle (
    vehicle_key     SERIAL PRIMARY KEY,
    vehicle_type    TEXT,
    vehicle_id      INT
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_dim_vehicle
    ON dim.dim_vehicle (vehicle_type, vehicle_id);

-- =========================================================
-- PERSON DIMENSION
-- =========================================================
CREATE TABLE IF NOT EXISTS dim.dim_person (
    person_key      SERIAL PRIMARY KEY,
    gender          TEXT,
    person_role     TEXT,
    age             SMALLINT CHECK (age >= 0),
    birth_year      SMALLINT
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_dim_person
    ON dim.dim_person (gender, person_role, age, birth_year);

COMMIT;

