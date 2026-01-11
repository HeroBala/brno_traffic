BEGIN;

-- STEP 1: Insert a NEW accident with SAME location
-- but CHANGED city_district (this triggers SCD)

INSERT INTO staging.stg_traffic_accident (
    accident_id,
    date,
    municipality_code,
    cadastral_area,
    city_district
)
VALUES (
    555555555,              -- test accident id
    DATE '2027-01-05',      -- future date
    'BRNO_TEST',            -- SAME municipality
    'CENTER',               -- SAME cadastral area
    'NEW_DISTRICT_NAME'     -- CHANGED attribute
);

COMMIT;

