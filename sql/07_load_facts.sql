BEGIN;

-- =========================================================
-- 0. OPTIONAL: TRUNCATE FACT TABLES
-- (recommended for full reloads)
-- =========================================================
TRUNCATE TABLE
    fact.fact_traffic_accident,
    fact.fact_weather_hourly,
    fact.fact_vehicle_traffic_intensity
RESTART IDENTITY;

-- =========================================================
-- 1. FACT: TRAFFIC ACCIDENT
-- Grain: 1 row = 1 accident
-- =========================================================
INSERT INTO fact.fact_traffic_accident (
    date_key,
    time_key,
    location_key,
    vehicle_key,
    person_key,
    accident_id,
    object_id,
    lightly_injured,
    seriously_injured,
    killed_persons,
    material_damage,
    vehicle_damage,
    death_flag,
    dq_invalid_time
)
SELECT
    -- Date
    d.date_key,

    -- Time
    t.time_key,

    -- Location
    l.location_key,

    -- Vehicle
    v.vehicle_key,

    -- Person
    p.person_key,

    -- Degenerate dimensions
    a.accident_id,
    a.object_id,

    -- Measures
    a.lightly_injured,
    a.seriously_injured,
    a.killed_persons,
    a.material_damage,
    a.vehicle_damage,

    -- Flags
    a.death_flag,
    a.dq_invalid_time

FROM core.traffic_accident_clean a

-- DATE
JOIN dim.dim_date d
  ON d.full_date = a.accident_date

-- TIME
LEFT JOIN dim.dim_time t
  ON t.time_key = a.time_hhmm

-- LOCATION
LEFT JOIN dim.dim_location l
  ON l.municipality_code = a.municipality_code
 AND l.city_district     = a.city_district
 AND l.cadastral_area    = a.cadastral_area

-- VEHICLE
LEFT JOIN dim.dim_vehicle v
  ON v.vehicle_type = a.vehicle_type
 AND v.vehicle_id   = a.vehicle_id

-- PERSON
LEFT JOIN dim.dim_person p
  ON p.gender       = a.gender
 AND p.person_role = a.person_role
 AND p.age         = a.age
 AND p.birth_year  = a.birth_year;

-- =========================================================
-- 2. FACT: WEATHER HOURLY
-- Grain: 1 row = 1 hour
-- =========================================================
INSERT INTO fact.fact_weather_hourly (
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
)
SELECT
    d.date_key,
    t.time_key,
    w.weather_key,

    -- Measures
    wh.temperature_2m,
    wh.dewpoint_2m,
    wh.apparent_temperature,
    wh.precipitation,
    wh.rain,
    wh.snowfall,
    wh.snow_depth,
    wh.windspeed_10m

FROM core.weather_hourly_clean wh

JOIN dim.dim_date d
  ON d.full_date = wh.weather_time::DATE

JOIN dim.dim_time t
  ON t.time_key =
     (EXTRACT(HOUR FROM wh.weather_time)::INT * 100 +
      EXTRACT(MINUTE FROM wh.weather_time)::INT)

JOIN dim.dim_weather w
  ON w.weathercode   = wh.weathercode
 AND w.cloudcover   = wh.cloudcover
 AND w.pressure_msl = wh.pressure_msl;

-- =========================================================
-- 3. FACT: VEHICLE TRAFFIC INTENSITY
-- Grain: location × year
-- =========================================================
INSERT INTO fact.fact_vehicle_traffic_intensity (
    location_key,
    year,
    car_count,
    truck_count
)
SELECT
    l.location_key,
    y.year,
    y.car_count,
    y.truck_count
FROM (
    SELECT
        object_id,
        2010 AS year, car_2010 AS car_count, truc_2010 AS truck_count FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2011, car_2011, truc_2011 FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2012, car_2012, truc_2012 FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2013, car_2013, truc_2013 FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2014, car_2014, truc_2014 FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2015, car_2015, truc_2015 FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2016, car_2016, truc_2016 FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2017, car_2017, truc_2017 FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2018, car_2018, truc_2018 FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2019, car_2019, truc_2019 FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2020, car_2020, truc_2020 FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2021, car_2021, truc_2021 FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2022, car_2022, truc_2022 FROM core.vehicle_traffic_intensity_clean
    UNION ALL
    SELECT object_id, 2023, car_2023, truc_2023 FROM core.vehicle_traffic_intensity_clean
) y
JOIN dim.dim_location l
  ON l.location_key = y.object_id;

COMMIT;

