BEGIN;

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
WHERE a._loaded_at >
      (SELECT last_processed_at
       FROM etl.etl_control
       WHERE process_name = 'load_facts')

ON CONFLICT (accident_id) DO NOTHING;

-- ✅ update watermark ONLY after successful insert
UPDATE etl.etl_control
SET last_processed_at = (
    SELECT COALESCE(MAX(_loaded_at), last_processed_at)
    FROM core.traffic_accident_clean
)
WHERE process_name = 'load_facts';

COMMIT;

