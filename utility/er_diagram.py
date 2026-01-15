from graphviz import Digraph

dot = Digraph(
    "Brno_Traffic_DWH",
    filename="brno_traffic_er_diagram",
    format="png"
)

dot.attr(rankdir="LR", fontsize="10")

# =========================
# DIMENSIONS
# =========================

dot.node(
    "DIM_DATE",
    """DIM_DATE
-------------------------
PK date_key
full_date
day
month
year
day_of_week
month_name
is_weekend
""",
    shape="box"
)

dot.node(
    "DIM_TIME",
    """DIM_TIME
-------------------------
PK time_key
hour
minute
time_label
""",
    shape="box"
)

dot.node(
    "DIM_WEATHER",
    """DIM_WEATHER
-------------------------
PK weather_key
weathercode
cloudcover
pressure_msl
""",
    shape="box"
)

dot.node(
    "DIM_LOCATION",
    """DIM_LOCATION (SCD Type 2)
-------------------------
PK location_key
object_id
municipality_code
city_district
cadastral_area
valid_from
valid_to
is_current
""",
    shape="box"
)

dot.node(
    "DIM_VEHICLE",
    """DIM_VEHICLE
-------------------------
PK vehicle_key
vehicle_type
vehicle_id
""",
    shape="box"
)

dot.node(
    "DIM_PERSON",
    """DIM_PERSON
-------------------------
PK person_key
gender
person_role
age
birth_year
""",
    shape="box"
)

# =========================
# FACT TABLES
# =========================

dot.node(
    "FACT_TRAFFIC_ACCIDENT",
    """FACT_TRAFFIC_ACCIDENT
-------------------------
PK accident_key

FK date_key
FK time_key (nullable)
FK location_key
FK vehicle_key (nullable)
FK person_key (nullable)

accident_id
object_id

lightly_injured
seriously_injured
killed_persons
material_damage
vehicle_damage

death_flag
dq_invalid_time
""",
    shape="ellipse"
)

dot.node(
    "FACT_WEATHER_HOURLY",
    """FACT_WEATHER_HOURLY
-------------------------
PK weather_fact_key

FK date_key
FK time_key
FK weather_key

temperature_2m
dewpoint_2m
apparent_temperature
precipitation
rain
snowfall
snow_depth
windspeed_10m
""",
    shape="ellipse"
)

dot.node(
    "FACT_VEHICLE_TRAFFIC_INTENSITY",
    """FACT_VEHICLE_TRAFFIC_INTENSITY
-------------------------
PK traffic_fact_key

FK location_key
year

car_count
truck_count
""",
    shape="ellipse"
)

# =========================
# RELATIONSHIPS
# =========================

# Traffic Accident
dot.edge("DIM_DATE", "FACT_TRAFFIC_ACCIDENT", label="1 : N")
dot.edge("DIM_TIME", "FACT_TRAFFIC_ACCIDENT", label="1 : 0..N")
dot.edge("DIM_LOCATION", "FACT_TRAFFIC_ACCIDENT", label="1 : N")
dot.edge("DIM_VEHICLE", "FACT_TRAFFIC_ACCIDENT", label="1 : 0..N")
dot.edge("DIM_PERSON", "FACT_TRAFFIC_ACCIDENT", label="1 : 0..N")

# Weather Hourly
dot.edge("DIM_DATE", "FACT_WEATHER_HOURLY", label="1 : N")
dot.edge("DIM_TIME", "FACT_WEATHER_HOURLY", label="1 : N")
dot.edge("DIM_WEATHER", "FACT_WEATHER_HOURLY", label="1 : N")

# Vehicle Traffic Intensity
dot.edge("DIM_LOCATION", "FACT_VEHICLE_TRAFFIC_INTENSITY", label="1 : N")

# =========================
# RENDER
# =========================

dot

