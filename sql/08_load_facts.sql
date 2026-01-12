BEGIN;

-- =========================================================
-- 1. FACT: TRAFFIC ACCIDENT
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
    d.date_key                                           AS date_key,
    COALESCE(t.time_key, -1)                             AS time_key,
    COALESCE(l.location_key, -1)                         AS location_key,
    COALESCE(v.vehicle_key, -1)                          AS vehicle_key,
    COALESCE(p.person_key, -1)                           AS person_key,
    a.accident_id,
    a.object_id,
    a.lightly_injured,
    a.seriously_injured,
    a.killed_persons,
    a.material_damage,
    a.vehicle_damage,
    a.death_flag,
    a.dq_invalid_time
FROM core.traffic_accident_clean a

-- DATE (MANDATORY)
JOIN dim.dim_date d
  ON d.full_date = a.accident_date

-- TIME (INVALID TIMES → UNKNOWN)
LEFT JOIN dim.dim_time t
  ON t.time_key = a.time_hhmm
 AND a.dq_invalid_time = 0

-- LOCATION (BUSINESS KEY = OBJECT_ID)
LEFT JOIN dim.dim_location l
  ON l.object_id = a.object_id
 AND l.is_current = TRUE

-- VEHICLE
LEFT JOIN dim.dim_vehicle v
  ON v.vehicle_type = a.vehicle_type
 AND v.vehicle_id   = a.vehicle_id

-- PERSON
LEFT JOIN dim.dim_person p
  ON p.gender       = a.gender
 AND p.person_role = a.person_role
 AND p.age         = a.age
 AND p.birth_year  = a.birth_year

ON CONFLICT (accident_id) DO NOTHING;

-- =========================================================
-- 2. FACT: WEATHER HOURLY
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
    c.temperature_2m,
    c.dewpoint_2m,
    c.apparent_temperature,
    c.precipitation,
    c.rain,
    c.snowfall,
    c.snow_depth,
    c.windspeed_10m
FROM core.weather_hourly_clean c

JOIN dim.dim_date d
  ON d.full_date = c.weather_time::DATE

JOIN dim.dim_time t
  ON t.hour   = EXTRACT(HOUR FROM c.weather_time)
 AND t.minute = EXTRACT(MINUTE FROM c.weather_time)

JOIN dim.dim_weather w
  ON w.weathercode  = c.weathercode
 AND w.cloudcover   = c.cloudcover
 AND w.pressure_msl = c.pressure_msl

ON CONFLICT (date_key, time_key) DO NOTHING;

-- =========================================================
-- 3. FACT: VEHICLE TRAFFIC INTENSITY
-- =========================================================

INSERT INTO fact.fact_vehicle_traffic_intensity (
    location_key,
    year,
    car_count,
    truck_count
)
SELECT
    COALESCE(l.location_key, -1) AS location_key,
    y.year,
    y.car_count,
    y.truck_count
FROM core.vehicle_traffic_intensity_clean v

CROSS JOIN LATERAL (
    VALUES
        (2010, v.car_2010, v.truc_2010),
        (2011, v.car_2011, v.truc_2011),
        (2012, v.car_2012, v.truc_2012),
        (2013, v.car_2013, v.truc_2013),
        (2014, v.car_2014, v.truc_2014),
        (2015, v.car_2015, v.truc_2015),
        (2016, v.car_2016, v.truc_2016),
        (2017, v.car_2017, v.truc_2017),
        (2018, v.car_2018, v.truc_2018),
        (2019, v.car_2019, v.truc_2019),
        (2020, v.car_2020, v.truc_2020),
        (2021, v.car_2021, v.truc_2021),
        (2022, v.car_2022, v.truc_2022),
        (2023, v.car_2023, v.truc_2023)
) AS y(year, car_count, truck_count)

LEFT JOIN dim.dim_location l
  ON l.object_id = v.object_id
 AND l.is_current = TRUE

WHERE y.car_count IS NOT NULL
   OR y.truck_count IS NOT NULL

ON CONFLICT (location_key, year) DO NOTHING;

COMMIT;

