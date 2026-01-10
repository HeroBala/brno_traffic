BEGIN;

-- =========================================================
-- DIMENSION SCHEMA
-- =========================================================
CREATE SCHEMA IF NOT EXISTS dim;

-- =========================================================
-- DATE DIMENSION
-- =========================================================
DROP TABLE IF EXISTS dim.dim_date CASCADE;

CREATE TABLE dim.dim_date (
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
DROP TABLE IF EXISTS dim.dim_time CASCADE;

CREATE TABLE dim.dim_time (
    time_key        INT PRIMARY KEY,           -- HHMM
    hour            SMALLINT NOT NULL CHECK (hour BETWEEN 0 AND 23),
    minute          SMALLINT NOT NULL CHECK (minute BETWEEN 0 AND 59),
    time_label      TEXT NOT NULL
);

-- =========================================================
-- LOCATION DIMENSION
-- =========================================================
DROP TABLE IF EXISTS dim.dim_location CASCADE;

CREATE TABLE dim.dim_location (
    location_key        SERIAL PRIMARY KEY,
    municipality_code   TEXT NOT NULL,
    city_district       TEXT NOT NULL,
    cadastral_area      TEXT NOT NULL,
    CONSTRAINT uq_dim_location UNIQUE (municipality_code, city_district, cadastral_area)
);

-- =========================================================
-- WEATHER DIMENSION
-- =========================================================
DROP TABLE IF EXISTS dim.dim_weather CASCADE;

CREATE TABLE dim.dim_weather (
    weather_key     SERIAL PRIMARY KEY,
    weathercode     INT,
    cloudcover      SMALLINT CHECK (cloudcover BETWEEN 0 AND 100),
    pressure_msl    DOUBLE PRECISION,
    CONSTRAINT uq_dim_weather UNIQUE (weathercode, cloudcover, pressure_msl)
);

-- =========================================================
-- VEHICLE DIMENSION
-- =========================================================
DROP TABLE IF EXISTS dim.dim_vehicle CASCADE;

CREATE TABLE dim.dim_vehicle (
    vehicle_key     SERIAL PRIMARY KEY,
    vehicle_type    TEXT,
    vehicle_id      INT,
    CONSTRAINT uq_dim_vehicle UNIQUE (vehicle_type, vehicle_id)
);

-- =========================================================
-- PERSON DIMENSION
-- =========================================================
DROP TABLE IF EXISTS dim.dim_person CASCADE;

CREATE TABLE dim.dim_person (
    person_key      SERIAL PRIMARY KEY,
    gender          TEXT,
    person_role     TEXT,
    age             SMALLINT CHECK (age >= 0),
    birth_year      SMALLINT,
    CONSTRAINT uq_dim_person UNIQUE (gender, person_role, age, birth_year)
);

COMMIT;

