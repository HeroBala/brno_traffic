````markdown
# Brno Traffic Accident Data Warehouse & Business Intelligence

This project implements a **full end-to-end data warehouse and business intelligence solution** for analyzing traffic accidents in the city of Brno.  
It integrates **traffic accident data, vehicle traffic intensity data, and weather data** into a PostgreSQL-based data warehouse and provides analytical insights using **Power BI**.

The solution follows **enterprise data warehousing best practices**, including layered ETL, dimensional modeling, Slowly Changing Dimensions (SCD Type 2), incremental loading, and BI-ready semantic views.

🔗 **Project Repository:**  
https://github.com/herobala/brno_traffic
👉 **[View Dashboard](https://app.powerbi.com/view?r=eyJrIjoiZTI3NWVkNmQtMDI2ZS00OGE4LTk1N2EtNjBjMTgyMGFhNmNhIiwidCI6IjBmYzM3OWMyLTlhYWMtNGExYy05ZmJkLWY0ZGMyMDk5OWU5YyIsImMiOjh9)**

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
````

---

## 📊 Data Sources

* **Traffic Accident Data (Brno Open Data):**
  [https://data.brno.cz/datasets/298c37feb1064873abdccdc2a10b605f_0/about](https://data.brno.cz/datasets/298c37feb1064873abdccdc2a10b605f_0/about)

* **Vehicle Traffic Intensity Data:**
  [https://data.brno.cz/datasets/dopravni-intenzita](https://data.brno.cz/datasets/dopravni-intenzita)

* **Weather Data (Open-Meteo API):**
  [https://archive-api.open-meteo.com/v1/archive](https://archive-api.open-meteo.com/v1/archive)

---

## 🧱 Data Warehouse Architecture

The solution follows a **layered ETL architecture**:

```
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
```

### Key Design Features

* Star schema optimized for analytics
* Slowly Changing Dimension (Type 2) for location history
* Incremental and idempotent ETL
* Data quality validation and auditing
* BI-friendly semantic layer

---

## 🗄️ PostgreSQL Schemas Used

* **staging** – Raw data loaded from CSV files
* **core** – Cleaned and validated views
* **dim** – Dimension tables
* **fact** – Fact tables
* **etl** – ETL control and watermark tracking
* **bi** – Read-only BI views for reporting

---

## 🚀 How to Run the Project

### 1️⃣ Prerequisites

* PostgreSQL 13+ installed
* `psql` command-line tool available
* Python 3.9+
* Power BI Desktop (for dashboards)

---

### 2️⃣ Clone the Repository

```bash
git clone https://github.com/herobala/brno_traffic.git
cd brno_traffic
```

---

### 3️⃣ Create PostgreSQL Database

```sql
CREATE DATABASE brno_traffic_dw;
```

Connect to it:

```bash
psql -d brno_traffic_dw
```

---

### 4️⃣ Run the Full ETL Pipeline (Recommended)

From inside `psql`:

```sql
\i sql/run_pipeline.sql
```

This single command will:

1. Create staging tables
2. Load CSV files
3. Create clean core views
4. Create dimension tables
5. Apply SCD Type 2 logic
6. Create fact tables
7. Load facts incrementally
8. Create BI views
9. Run sanity checks

---

### 5️⃣ Verify Data Quality

Optional but recommended:

```sql
\i sql/09_sanity_check.sql
```

---

## 🔁 Incremental Loading & SCD Demo

The project includes ready-to-run demos:

* **Incremental loading test:**

  ```sql
  \i sql/11_test_incremental_loading.sql
  ```

* **Incremental loading proof:**

  ```sql
  \i sql/12_proof_incremental_loading.sql
  ```

* **SCD Type 2 location demo:**

  ```sql
  \i sql/13_demo_scd_location.sql
  ```

---

## 📈 Power BI Usage

1. Open `documents/brno_traffic.pbix` in **Power BI Desktop**
2. Update database connection if needed
3. Refresh data
4. Explore:

   * KPI dashboard
   * Trend & seasonality analysis
   * Weather impact analysis
   * Spatial hotspot analysis

---

## 🐍 Python Utilities

Install dependencies:

```bash
pip install -r requirements.txt
```

Key scripts:

* `weather_data.py` – Fetches weather data from Open-Meteo
* `data_profiler.py` – Dataset profiling and quality checks
* `dw_insight_analysis.py` – Analytical summaries
* `er_diagram.py` – ER diagram generation
* `load_csv_to_pandas.py` – CSV inspection
* `export_*` scripts – Export warehouse tables

---

## 🔍 Reproducibility & Reliability

* One-command ETL execution
* Incremental-safe re-runs
* Full referential integrity
* Grain protection via constraints
* Audit timestamps on all layers

---

## 📄 Documentation

* Full project report:
  `documents/Brno_Traffic_Accident_Data_Warehouse.docx`

* ER Diagram:
  `documents/brno_traffic_er_diagram.png`

---

## 📌 Notes

* All SQL scripts are **PostgreSQL-specific**
* CSV paths assume project root structure
* Designed for academic, learning, and demonstration purposes

---

## 🏁 License & Usage

This project is intended for **educational and academic use**.
Data sources are governed by their respective open data licenses.

---

## 👤 Author

**Hero Bala**
Course: ENA-BIDS

---

✅ **You are now ready to clone, run, analyze, and extend this project.**

