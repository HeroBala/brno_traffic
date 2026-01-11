HOW TO RUN THE DATA WAREHOUSE PIPELINE
1️⃣ INITIAL SETUP (RUN ONCE)

Use this when setting up the database for the first time.
=> 00 → 01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → sanity

2️⃣ NORMAL INCREMENTAL RUN (REPEATABLE)

Use this when new data arrives.

=> 02 → 03 → 05 → 05b → 08 → 09 → sanity

3️⃣ TEST INCREMENTAL LOADING (DEMO)

Shows that only new rows are loaded.
=> 11 → 05 → 05b → 03 → 08 → 12

4️⃣ TEST SCD TYPE 2 (DEMO)

Shows history tracking in dimensions.
=> 13 → 05b → 14
