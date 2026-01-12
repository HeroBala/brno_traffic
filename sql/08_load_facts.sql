BEGIN;

-- =========================================================
-- 1. FACT: TRAFFIC ACCIDENT (INCREMENTAL)
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
    d.date_key,
    t.time_key,
    l.location_key,
    v.vehicle_key,
    p.person_key,
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
JOIN dim.dim_date d
  ON d.full_date = a.accident_date
LEFT JOIN dim.dim_time t
  ON t.time_key = a.time_hhmm
LEFT JOIN dim.dim_location l
  ON l.municipality_code = a.municipality_code
 AND l.cadastral_area    = a.cadastral_area
 AND a.accident_date BETWEEN l.valid_from AND l.valid_to
LEFT JOIN dim.dim_vehicle v
  ON v.vehicle_type = a.vehicle_type
 AND v.vehicle_id   = a.vehicle_id
LEFT JOIN dim.dim_person p
  ON p.gender       = a.gender
 AND p.person_role = a.person_role
 AND p.age         = a.age
 AND p.birth_year  = a.birth_year
ON CONFLICT (accident_id) DO NOTHING;

-- =========================================================
-- 2. FACT: WEATHER HOURLY (IDEMPOTENT)
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
-- 3. FACT: VEHICLE TRAFFIC INTENSITY (CORRECT UNPIVOT)
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
JOIN dim.dim_location l
  ON l.location_key = v.object_id
WHERE y.car_count IS NOT NULL
   OR y.truck_count IS NOT NULL
ON CONFLICT (location_key, year) DO NOTHING;

COMMIT;

