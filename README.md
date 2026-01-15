# Brno Traffic Accident Data Warehouse & Business Intelligence

This project implements a **full end-to-end data warehouse and business intelligence solution** for analyzing traffic accidents in the city of Brno.  
It integrates **traffic accident data, vehicle traffic intensity data, and weather data** into a PostgreSQL-based data warehouse and provides analytical insights using **Power BI**.

The solution follows **enterprise data warehousing best practices**, including layered ETL, dimensional modeling, Slowly Changing Dimensions (SCD Type 2), incremental loading, and BI-ready semantic views.

🔗 **Project Repository:**  
[https://github.com/herobala/brno_traffic](https://github.com/herobala/brno_traffic)

---

## 📊 Power BI Dashboard

> Click the image below to open the interactive Power BI dashboard.

[![Power BI Dashboard](dashboard.png)](https://app.powerbi.com/view?r=eyJrIjoiZTI3NWVkNmQtMDI2ZS00OGE4LTk1N2EtNjBjMTgyMGFhNmNhIiwidCI6IjBmYzM3OWMyLTlhYWMtNGExYy05ZmJkLWY0ZGMyMDk5OWU5YyIsImMiOjh9)

---

## 🧰 Technologies Used

- **PostgreSQL (psql)** – Data warehouse and ETL implementation  
- **SQL (PostgreSQL dialect only)** – All SQL scripts are written specifically for `psql`  
- **Python** – Data acquisition, profiling, and analysis utilities  
- **Power BI** – Business intelligence dashboards and reports  

> ⚠️ **Important:**  
> All SQL scripts in this repository are written for **PostgreSQL (psql)** and are **not compatible** with MySQL, SQL Server, or Oracle without modification.

---

## 📁 Project Structure

```text
├── csv
│   ├── brno_weather_2017_2024.csv
│   ├── traffic_accident.csv
│   └── vehicle_traffic_intensity.csv
│
├── documents
│   ├── Brno_Traffic_Accident_Data_Warehouse.docx
│   ├── brno_traffic.pbix
│   └── brno_traffic_er_diagram.png
│
├── requirements.txt
│
├── sql
│   ├── 00_inspect_database.sql
│   ├── 01_create_staging.sql
│   ├── 02_load_csv.sql
│   ├── 03_core_cleaning.sql
│   ├── 04_create_dimensions.sql
│   ├── 05_load_dimensions.sql
│   ├── 05b_scd_location.sql
│   ├── 06_create_facts.sql
│   ├── 07_etl_control.sql
│   ├── 08_load_facts.sql
│   ├── 09_create_BI_views.sql
│   ├── 09_sanity_check.sql
│   ├── 11_test_incremental_loading.sql
│   ├── 12_proof_incremental_loading.sql
│   ├── 13_demo_scd_location.sql
│   └── run_pipeline.sql
│
└── utility
    ├── data_profiler.py
    ├── dw_insight_analysis.py
    ├── er_diagram.py
    ├── export_all_dim_fact.sh
    ├── export_bi_tables.sh
    ├── load_csv_to_pandas.py
    └── weather_data.py
📊 Data Sources
Traffic Accident Data (Brno Open Data):
https://data.brno.cz/datasets/298c37feb1064873abdccdc2a10b605f_0/about

Vehicle Traffic Intensity Data:
https://data.brno.cz/datasets/dopravni-intenzita

Weather Data (Open-Meteo API):
https://archive-api.open-meteo.com/v1/archive

🧱 Data Warehouse Architecture
The solution follows a layered ETL architecture:

text
Copy code
CSV Source Files
   ↓
Staging Layer
   ↓
Core Cleaning & Validation Views
   ↓
Dimensional Data Warehouse (Star Schema)
   ↓
BI Views
   ↓
Power BI Dashboards
Key Design Features
Star schema optimized for analytics

Slowly Changing Dimension (Type 2) for location history

Incremental and idempotent ETL

Data quality validation and auditing

BI-friendly semantic layer

🗄️ PostgreSQL Schemas Used
staging – Raw data loaded from CSV files

core – Cleaned and validated views

dim – Dimension tables

fact – Fact tables

etl – ETL control and watermark tracking

bi – Read-only BI views for reporting

🚀 How to Run the Project
1️⃣ Prerequisites
PostgreSQL 13+

psql command-line tool

Python 3.9+

Power BI Desktop

2️⃣ Clone the Repository
bash
Copy code
git clone https://github.com/herobala/brno_traffic.git
cd brno_traffic
3️⃣ Create PostgreSQL Database
sql
Copy code
CREATE DATABASE brno_traffic_dw;
bash
Copy code
psql -d brno_traffic_dw
4️⃣ Run the Full ETL Pipeline
sql
Copy code
\i sql/run_pipeline.sql
5️⃣ Verify Data Quality
sql
Copy code
\i sql/09_sanity_check.sql
🔁 Incremental Loading & SCD Demo
Incremental loading test:

sql
Copy code
\i sql/11_test_incremental_loading.sql
Incremental loading proof:

sql
Copy code
\i sql/12_proof_incremental_loading.sql
SCD Type 2 demo:

sql
Copy code
\i sql/13_demo_scd_location.sql
📈 Power BI Usage
Open documents/brno_traffic.pbix

Update database connection if needed

Refresh data

Explore dashboards and insights

🐍 Python Utilities
bash
Copy code
pip install -r requirements.txt
Key scripts include:

weather_data.py

data_profiler.py

dw_insight_analysis.py

er_diagram.py

📄 Documentation
Full project report:
documents/Brno_Traffic_Accident_Data_Warehouse.docx

ER Diagram:
documents/brno_traffic_er_diagram.png

👤 Author
Hero Bala
Course: ENA-BIDS

✅ You are now ready to clone, run, analyze, and extend this project.
