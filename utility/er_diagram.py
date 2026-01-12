from graphviz import Digraph
from pathlib import Path

# =========================================================
# OUTPUT PATH
# =========================================================
output_dir = Path.home() / "brno_traffic" / "documents"
output_dir.mkdir(parents=True, exist_ok=True)
output_path = output_dir / "brno_traffic_er_diagram_large_text"

# =========================================================
# GRAPH SETUP
# =========================================================
dot = Digraph(
    "Brno Traffic ER Diagram",
    format="png",
    graph_attr={
        "rankdir": "LR",
        "splines": "ortho",
        "nodesep": "1.1",
        "ranksep": "1.4",
        "fontname": "Helvetica",
        "bgcolor": "white"
    }
)

# =========================================================
# DEFAULT NODE STYLE (BIGGER TEXT)
# =========================================================
dot.attr(
    "node",
    shape="box",
    style="rounded,filled",
    fontname="Helvetica",
    fontsize="13",        # ⬅️ bigger text
    margin="0.18,0.12",   # ⬅️ more padding
    color="#455A64",
    fontcolor="#000000"
)

# =========================================================
# EDGE STYLE (BIGGER LABELS)
# =========================================================
dot.attr(
    "edge",
    fontname="Helvetica",
    fontsize="12",
    color="#424242"
)

# =========================================================
# COLOR PALETTE
# =========================================================
DIM_COLOR  = "#E3F2FD"   # light blue
FACT_COLOR = "#FFF3E0"   # light orange

# =========================================================
# DIMENSIONS
# =========================================================
dot.node("DIM_DATE", """DIM_DATE
PK date_key
full_date
day
month
year
day_of_week
month_name
is_weekend""", fillcolor=DIM_COLOR)

dot.node("DIM_TIME", """DIM_TIME
PK time_key
hour
minute
time_label""", fillcolor=DIM_COLOR)

dot.node("DIM_LOCATION", """DIM_LOCATION
PK location_key
object_id
municipality_code
city_district
cadastral_area
valid_from
valid_to
is_current""", fillcolor=DIM_COLOR)

dot.node("DIM_VEHICLE", """DIM_VEHICLE
PK vehicle_key
vehicle_type
vehicle_id""", fillcolor=DIM_COLOR)

dot.node("DIM_PERSON", """DIM_PERSON
PK person_key
gender
person_role
age
birth_year""", fillcolor=DIM_COLOR)

dot.node("DIM_WEATHER", """DIM_WEATHER
PK weather_key
weathercode
cloudcover
pressure_msl""", fillcolor=DIM_COLOR)

# =========================================================
# FACTS
# =========================================================
dot.node("FACT_TRAFFIC_ACCIDENT", """FACT_TRAFFIC_ACCIDENT
PK accident_key
FK date_key
FK time_key (nullable)
FK location_key
FK vehicle_key (nullable)
FK person_key (nullable)
accident_id
lightly_injured
seriously_injured
killed_persons
material_damage
vehicle_damage
death_flag
dq_invalid_time""", fillcolor=FACT_COLOR)

dot.node("FACT_WEATHER_HOURLY", """FACT_WEATHER_HOURLY
PK weather_fact_key
FK date_key
FK time_key
FK weather_key
temperature_2m
precipitation
windspeed_10m""", fillcolor=FACT_COLOR)

dot.node("FACT_VEHICLE_TRAFFIC_INTENSITY", """FACT_VEHICLE_TRAFFIC_INTENSITY
PK traffic_fact_key
FK location_key
year
car_count
truck_count""", fillcolor=FACT_COLOR)

# =========================================================
# RELATIONSHIPS (ER CARDINALITY)
# =========================================================
dot.edge("DIM_DATE", "FACT_TRAFFIC_ACCIDENT", label="1 : N")
dot.edge("DIM_TIME", "FACT_TRAFFIC_ACCIDENT", label="1 : 0..N")
dot.edge("DIM_LOCATION", "FACT_TRAFFIC_ACCIDENT", label="1 : N")
dot.edge("DIM_VEHICLE", "FACT_TRAFFIC_ACCIDENT", label="1 : 0..N")
dot.edge("DIM_PERSON", "FACT_TRAFFIC_ACCIDENT", label="1 : 0..N")

dot.edge("DIM_DATE", "FACT_WEATHER_HOURLY", label="1 : N")
dot.edge("DIM_TIME", "FACT_WEATHER_HOURLY", label="1 : N")
dot.edge("DIM_WEATHER", "FACT_WEATHER_HOURLY", label="1 : N")

dot.edge("DIM_LOCATION", "FACT_VEHICLE_TRAFFIC_INTENSITY", label="1 : N")

# =========================================================
# RENDER
# =========================================================
dot.render(str(output_path), cleanup=True)

print(f"ER diagram saved to: {output_path}.png")

