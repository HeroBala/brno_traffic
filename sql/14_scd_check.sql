-- CHECK 1: Show all versions of the location

SELECT
    location_key,
    municipality_code,
    cadastral_area,
    city_district,
    valid_from,
    valid_to,
    is_current
FROM dim.dim_location
WHERE municipality_code = 'BRNO_TEST'
  AND cadastral_area = 'CENTER'
ORDER BY valid_from;

