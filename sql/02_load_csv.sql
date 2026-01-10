BEGIN;

-- =====================================================
-- VEHICLE TRAFFIC INTENSITY
-- =====================================================

TRUNCATE TABLE staging.stg_vehicle_traffic_intensity;

COPY staging.stg_vehicle_traffic_intensity (
    id,
    car_2010, truc_2010,
    car_2011, truc_2011,
    car_2012, truc_2012,
    car_2013, truc_2013,
    car_2014, truc_2014,
    car_2015, truc_2015,
    car_2016, truc_2016,
    car_2017, truc_2017,
    car_2018, truc_2018,
    car_2019, truc_2019,
    car_2020, truc_2020,
    car_2021, truc_2021,
    car_2022, truc_2022,
    car_2023, truc_2023,
    datum_exportu,
    objectid,
    shape__length,
    globalid
)
FROM '/csv/vehicle_traffic_intensity.csv'
WITH (
    FORMAT csv,
    HEADER true
);

-- =====================================================
-- WEATHER (HOURLY)
-- =====================================================

TRUNCATE TABLE staging.stg_weather_hourly;

COPY staging.stg_weather_hourly (
    time,
    temperature_2m,
    relativehumidity_2m,
    dewpoint_2m,
    apparent_temperature,
    precipitation,
    rain,
    snowfall,
    snow_depth,
    weathercode,
    windspeed_10m,
    cloudcover,
    pressure_msl
)
FROM '/csv/brno_weather_2017_2024.csv'
WITH (
    FORMAT csv,
    HEADER true
);

-- =====================================================
-- TRAFFIC ACCIDENTS
-- =====================================================

TRUNCATE TABLE staging.stg_traffic_accident;

COPY staging.stg_traffic_accident (
    object_id,
    municipality_code,
    alcohol_offender,
    main_cause,
    collision_type,
    consequences,
    cause,
    road_condition,
    weather_conditions,
    visibility_range,
    accident_location,
    road_type,
    vehicle_type,
    city_district,
    gender,
    alcohol,
    day_of_week,
    month_text,
    cadastral_area,
    result,
    person_role,
    fault,
    lighting_conditions,
    road_situation,
    person,
    driver_condition,
    time_period,
    local_code,
    target_fid,
    join_count,
    object_id_1,
    join_count_1,
    target_fid_1,
    day,
    age,
    death_days,
    birth_year,
    police_code_p48a,
    police_code_p59d,
    year,
    event_type,
    death_flag,
    lightly_injured,
    seriously_injured,
    killed_persons,
    vehicle_id,
    hour,
    driver_influence,
    time,
    month,
    accident_id,
    date,
    material_damage,
    vehicle_damage,
    global_id
)
FROM '/csv/traffic_accident.csv'
WITH (
    FORMAT csv,
    HEADER true
);

COMMIT;

