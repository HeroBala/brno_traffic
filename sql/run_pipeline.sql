\echo '======================================'
\echo ' BRNO TRAFFIC DATA WAREHOUSE PIPELINE '
\echo '======================================'

\echo '01 - Create staging schema & tables'
\i sql/01_create_staging.sql

\echo '02 - Load CSV files into staging'
\i sql/02_load_csv.sql

\echo '03 - Create / refresh core clean views'
\i sql/03_core_cleaning.sql

\echo '04 - Create dimension tables'
\i sql/04_create_dimensions.sql

\echo '05 - Load dimension tables'
\i sql/05_load_dimensions.sql

\echo '05b - Apply SCD Type 2 logic (Location)'
\i sql/05b_scd_location.sql

\echo '06 - Create fact tables'
\i sql/06_create_facts.sql

\echo '07 - Create ETL control table'
\i sql/07_etl_control.sql

\echo '08 - Load fact tables (incremental-safe)'
\i sql/08_load_facts.sql

\echo '======================================'
\echo ' PIPELINE COMPLETED SUCCESSFULLY '
\echo '======================================'

