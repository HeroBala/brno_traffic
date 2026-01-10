BEGIN;

CREATE SCHEMA IF NOT EXISTS bi;

-- =========================================================
-- 1. BI VIEW: TRAFFIC ACCIDENTS (MAIN ANALYTICS VIEW)
-- =========================================================
DROP VIEW IF EXISTS bi.vw_traffic_accidents;

CREATE VIEW bi.vw_traffic_accidents AS
SELECT
    -- Date
    d.full_date,
    d.year,
    d.month,
    d.month_name,
    d.day,
    d.day_of_week,
    d.is_weekend,

    -- Time
    t.hour,
    t.minute,
    t.time_label,

    -- Location
    l.municipality_code,
    l.city_district,
    l.cadastral_area,

    -- Vehicle
    v.vehicle_type,
    v.vehicle_id,

    -- Person
    p.gender,
    p.person_role,
    p.age,
    p.birth_year,

    -- Degenerate dimensions
    f.accident_id,
    f.object_id,

    -- Measures
    f.lightly_injured,
    f.seriously_injured,
    f.killed_persons,
    f.material_damage,
    f.vehicle_damage,

    -- Flags
    f.death_flag,
    f.dq_invalid_time,

    -- Audit
    f._fact_loaded_at

FROM fact.fact_traffic_accident f
JOIN dim.dim_date d       ON d.date_key = f.date_key
LEFT JOIN dim.dim_time t  ON t.time_key = f.time_key
LEFT JOIN dim.dim_location l ON l.location_key = f.location_key
LEFT JOIN dim.dim_vehicle v  ON v.vehicle_key = f.vehicle_key
LEFT JOIN dim.dim_person p   ON p.person_key = f.person_key;

-- =========================================================
-- 2. BI VIEW: WEATHER HOURLY
-- =========================================================
DROP VIEW IF EXISTS bi.vw_weather_hourly;

CREATE VIEW bi.vw_weather_hourly AS
SELECT
    -- Date & Time
    d.full_date,
    d.year,
    d.month,
    d.month_name,
    d.day,
    d.day_of_week,
    t.hour,
    t.minute,
    t.time_label,

    -- Weather description
    w.weathercode,
    w.cloudcover,
    w.pressure_msl,

    -- Measures
    f.temperature_2m,
    f.dewpoint_2m,
    f.apparent_temperature,
    f.precipitation,
    f.rain,
    f.snowfall,
    f.snow_depth,
    f.windspeed_10m,

    -- Audit
    f._fact_loaded_at

FROM fact.fact_weather_hourly f
JOIN dim.dim_date d      ON d.date_key = f.date_key
JOIN dim.dim_time t      ON t.time_key = f.time_key
JOIN dim.dim_weather w   ON w.weather_key = f.weather_key;

-- =========================================================
-- 3. BI VIEW: VEHICLE TRAFFIC INTENSITY (YEARLY)
-- =========================================================
DROP VIEW IF EXISTS bi.vw_vehicle_traffic_intensity;

CREATE VIEW bi.vw_vehicle_traffic_intensity AS
SELECT
    -- Location
    l.municipality_code,
    l.city_district,
    l.cadastral_area,

    -- Time
    f.year,

    -- Measures
    f.car_count,
    f.truck_count,
    (f.car_count + f.truck_count) AS total_vehicles,

    -- Audit
    f._fact_loaded_at

FROM fact.fact_vehicle_traffic_intensity f
JOIN dim.dim_location l
  ON l.location_key = f.location_key;

COMMIT;

