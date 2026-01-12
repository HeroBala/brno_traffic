-- =====================================================
-- 1. BI SCHEMA
-- =====================================================
CREATE SCHEMA IF NOT EXISTS bi;

-- =====================================================
-- 2. DIMENSION VIEWS
-- =====================================================

-- ---------- DIM DATE ----------
CREATE OR REPLACE VIEW bi.dim_date AS
SELECT
    date_key,
    full_date::date AS full_date,
    day,
    month,
    year,
    day_of_week,
    month_name,
    (is_weekend = 't') AS is_weekend
FROM dim.dim_date;

-- ---------- DIM TIME ----------
CREATE OR REPLACE VIEW bi.dim_time AS
SELECT
    time_key,
    hour,
    minute,
    time_label
FROM dim.dim_time;

-- ---------- DIM VEHICLE ----------
CREATE OR REPLACE VIEW bi.dim_vehicle AS
SELECT
    vehicle_key,
    vehicle_type
FROM dim.dim_vehicle;

-- ---------- DIM PERSON ----------
CREATE OR REPLACE VIEW bi.dim_person AS
SELECT
    person_key,
    gender,
    person_role,
    age,
    birth_year
FROM dim.dim_person;

-- ---------- DIM WEATHER ----------
CREATE OR REPLACE VIEW bi.dim_weather AS
SELECT
    weather_key,
    weathercode,
    cloudcover,
    pressure_msl
FROM dim.dim_weather;

-- ---------- DIM LOCATION (SCD TYPE 2 READY) ----------
CREATE OR REPLACE VIEW bi.dim_location AS
SELECT
    location_key,
    object_id,
    municipality_code,
    city_district,
    cadastral_area,
    valid_from::date AS valid_from,
    valid_to::date   AS valid_to,
    (is_current = 't') AS is_current
FROM dim.dim_location;

-- =====================================================
-- 3. FACT VIEWS (ATOMIC GRAIN)
-- =====================================================

-- ---------- FACT TRAFFIC ACCIDENT ----------
CREATE OR REPLACE VIEW bi.fact_traffic_accident AS
SELECT
    accident_key,
    date_key,
    time_key,
    location_key,
    vehicle_key,
    person_key,

    lightly_injured,
    seriously_injured,
    killed_persons,

    material_damage,
    vehicle_damage,

    (death_flag = 1)       AS death_flag,
    (dq_invalid_time = 1) AS invalid_time_flag
FROM fact.fact_traffic_accident;

-- ---------- FACT TRAFFIC INTENSITY ----------
CREATE OR REPLACE VIEW bi.fact_traffic_intensity AS
SELECT
    traffic_fact_key,
    location_key,
    year,
    car_count,
    truck_count,
    car_count + truck_count AS total_vehicles
FROM fact.fact_vehicle_traffic_intensity;

-- ---------- FACT WEATHER HOURLY ----------
CREATE OR REPLACE VIEW bi.fact_weather_hourly AS
SELECT
    weather_fact_key,
    date_key,
    time_key,
    weather_key,

    temperature_2m,
    dewpoint_2m,
    apparent_temperature,

    precipitation,
    rain,
    snowfall,
    snow_depth,
    windspeed_10m
FROM fact.fact_weather_hourly;

-- =====================================================
-- 4. DENORMALIZED WIDE FACT VIEW
-- =====================================================

CREATE OR REPLACE VIEW bi.fact_traffic_accident_wide AS
SELECT
    f.accident_key,

    -- Date
    d.full_date,
    d.year,
    d.month,
    d.day_of_week,
    d.is_weekend,

    -- Time
    t.hour,
    t.minute,

    -- Location
    l.municipality_code,
    l.city_district,
    l.cadastral_area,

    -- Vehicle
    v.vehicle_type,

    -- Person
    p.gender,
    p.person_role,
    p.age,

    -- Measures
    f.lightly_injured,
    f.seriously_injured,
    f.killed_persons,
    f.material_damage,
    f.vehicle_damage,
    f.death_flag

FROM bi.fact_traffic_accident f
LEFT JOIN bi.dim_date     d ON f.date_key     = d.date_key
LEFT JOIN bi.dim_time     t ON f.time_key     = t.time_key
LEFT JOIN bi.dim_location l ON f.location_key = l.location_key
                           AND l.is_current
LEFT JOIN bi.dim_vehicle  v ON f.vehicle_key  = v.vehicle_key
LEFT JOIN bi.dim_person   p ON f.person_key   = p.person_key;

