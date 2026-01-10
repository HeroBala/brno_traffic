from graphviz import Digraph

# =====================================================
# COLORS
# =====================================================
COLOR_FACT = "#F6B6B6"
COLOR_DIM = "#D8ECFF"
COLOR_TIME = "#FFF4C2"
COLOR_SPATIAL = "#DFF3E3"

# =====================================================
# GRAPH SETUP
# =====================================================
er = Digraph(
    "Traffic_DW_ERD_Final",
    format="png",
    graph_attr={
        "rankdir": "TB",          # TOP → BOTTOM stars
        "splines": "ortho",
        "nodesep": "1.2",
        "ranksep": "1.4",
        "fontname": "Helvetica"
    }
)

er.attr("edge", arrowsize="0.8", penwidth="1.2", color="#444444")

# =====================================================
# TABLE HELPER
# =====================================================
def table(name, columns, color):
    label = f"<<TABLE BORDER='1' CELLBORDER='1' CELLSPACING='0' CELLPADDING='6' BGCOLOR='{color}'>"
    label += f"<TR><TD><B>{name}</B></TD></TR>"
    for col in columns:
        label += f"<TR><TD ALIGN='LEFT'>{col}</TD></TR>"
    label += "</TABLE>>"
    er.node(name, label=label, shape="plaintext")

# =====================================================
# DIMENSIONS
# =====================================================

table("dim_date", [
    "date_key (PK)",
    "full_date",
    "day",
    "month",
    "year",
    "day_of_week",
    "month_name",
    "is_weekend"
], COLOR_TIME)

table("dim_time", [
    "time_key (PK)",
    "hour",
    "minute",
    "time_label"
], COLOR_TIME)

table("dim_weather", [
    "weather_key (PK)",
    "weathercode",
    "cloudcover",
    "pressure_msl"
], COLOR_DIM)

table("dim_vehicle", [
    "vehicle_key (PK)",
    "vehicle_id",
    "vehicle_type"
], COLOR_DIM)

table("dim_person", [
    "person_key (PK)",
    "gender",
    "person_role",
    "age",
    "birth_year"
], COLOR_DIM)

table("dim_location", [
    "location_key (PK)",
    "municipality_code",
    "city_district",
    "cadastral_area"
], COLOR_SPATIAL)

# =====================================================
# FACT TABLES
# =====================================================

table("fact_weather_hourly", [
    "weather_fact_key (PK)",
    "date_key (FK)",
    "time_key (FK)",
    "weather_key (FK)",
    "temperature_2m",
    "dewpoint_2m",
    "apparent_temperature",
    "precipitation",
    "rain",
    "snowfall",
    "snow_depth",
    "windspeed_10m"
], COLOR_FACT)

table("fact_traffic_accident", [
    "accident_key (PK)",
    "date_key (FK)",
    "time_key (FK)",
    "location_key (FK)",
    "vehicle_key (FK)",
    "person_key (FK)",
    "accident_id (DD)",
    "object_id (DD)",
    "lightly_injured",
    "seriously_injured",
    "killed_persons",
    "material_damage",
    "vehicle_damage",
    "death_flag",
    "dq_invalid_time"
], COLOR_FACT)

table("fact_vehicle_traffic_intensity", [
    "traffic_fact_key (PK)",
    "location_key (FK)",
    "year",
    "car_count",
    "truck_count"
], COLOR_FACT)

# =====================================================
# RANKING (THIS FIXES YOUR LAYOUT)
# =====================================================

# Weather star (TOP)
with er.subgraph() as s:
    s.attr(rank="same")
    s.node("dim_weather")
    s.node("dim_date")
    s.node("dim_time")

with er.subgraph() as s:
    s.attr(rank="same")
    s.node("fact_weather_hourly")

# Accident star (CENTER)
with er.subgraph() as s:
    s.attr(rank="same")
    s.node("dim_vehicle")
    s.node("dim_person")
    s.node("fact_traffic_accident")
    s.node("dim_location")

# Traffic intensity star (BOTTOM)
with er.subgraph() as s:
    s.attr(rank="same")
    s.node("fact_vehicle_traffic_intensity")

# =====================================================
# RELATIONSHIPS
# =====================================================

# Weather
er.edge("dim_date", "fact_weather_hourly")
er.edge("dim_time", "fact_weather_hourly")
er.edge("dim_weather", "fact_weather_hourly")

# Accident
er.edge("dim_date", "fact_traffic_accident")
er.edge("dim_time", "fact_traffic_accident")
er.edge("dim_vehicle", "fact_traffic_accident")
er.edge("dim_person", "fact_traffic_accident")
er.edge("dim_location", "fact_traffic_accident")

# Traffic intensity
er.edge("dim_location", "fact_vehicle_traffic_intensity")

# =====================================================
# RENDER
# =====================================================
er.render("traffic_dw_erd_star_layout", cleanup=True)

