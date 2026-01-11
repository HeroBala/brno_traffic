-- STEP 1: show current fact count
SELECT COUNT(*) AS accidents_before
FROM fact.fact_traffic_accident;

-- STEP 2: insert ONE brand-new accident into STAGING
INSERT INTO staging.stg_traffic_accident (
    accident_id,
    object_id,
    municipality_code,
    cadastral_area,
    city_district,
    date,
    time,
    vehicle_type,
    vehicle_id,
    gender,
    person_role,
    age,
    birth_year,
    lightly_injured,
    seriously_injured,
    killed_persons,
    material_damage,
    vehicle_damage,
    death_flag
)
VALUES (
    99999999,
    99999999,
    'BRNO_TEST',
    'CENTER',
    'TEST_DISTRICT',
    CURRENT_DATE,
    1230,
    'CAR',
    1,
    'M',
    'DRIVER',
    30,
    1994,
    0,
    0,
    0,
    1000,
    500,
    0
);


