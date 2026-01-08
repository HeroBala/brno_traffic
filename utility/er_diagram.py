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
    "Traffic_DW_ERD_Star",
    format="svg",
    graph_attr={
        "rankdir": "LR",
        "splines": "ortho",
        "nodesep": "1.0",
        "ranksep": "1.4",
        "fontname": "Helvetica"
    }
)

er.attr("edge", color="#444444", arrowsize="0.8", penwidth="1.2")

# =====================================================
# TABLE HELPER
# =====================================================
def table(name, columns, color):
    label = f"<<TABLE BORDER='1' CELLBORDER='1' CELLSPACING='0' CELLPADDING='6' BGCOLOR='{color}'>"
    label += f"<TR><TD COLSPAN='2'><B>{name}</B></TD></TR>"
    for col in columns:
        label += f"<TR><TD ALIGN='LEFT' COLSPAN='2'>{col}</TD></TR>"
    label += "</TABLE>>"
    er.node(name, label=label, shape="plaintext")

# =====================================================
# FACT TABLES (CENTER ANCHORS)
# =====================================================

table("FactTrafficAccident", [
    "AccidentFactKey (PK)",
    "accident_id (DD)",
    "object_id (DD)",
    "TimeKey (FK)",
    "LocationKey (FK)",
    "VehicleKey (FK)",
    "PersonKey (FK)",
    "WeatherConditionKey (FK)",
    "──────────",
    "event_type",
    "death_flag",
    "lightly_injured",
    "seriously_injured",
    "killed_persons",
    "material_damage",
    "vehicle_damage"
], COLOR_FACT)

table("FactWeather", [
    "WeatherFactKey (PK)",
    "TimeKey (FK)",
    "WeatherTypeKey (FK)",
    "──────────",
    "temperature_2m",
    "relativehumidity_2m",
    "dewpoint_2m",
    "apparent_temperature",
    "precipitation",
    "rain",
    "snowfall",
    "snow_depth",
    "windspeed_10m",
    "cloudcover",
    "pressure_msl"
], COLOR_FACT)

table("FactTrafficIntensity", [
    "TrafficIntensityFactKey (PK)",
    "RoadSegmentKey (FK)",
    "TimeKey (FK)",
    "──────────",
    "vehicle_type",
    "vehicle_count"
], COLOR_FACT)

# =====================================================
# DIMENSIONS
# =====================================================

table("DimTime", [
    "TimeKey (PK)",
    "date",
    "year",
    "month",
    "day",
    "hour",
    "day_of_week",
    "time_period"
], COLOR_TIME)

table("DimLocation", [
    "LocationKey (PK)",
    "municipality_code",
    "city_district",
    "cadastral_area",
    "road_type",
    "road_situation",
    "accident_location"
], COLOR_SPATIAL)

table("DimVehicle", [
    "VehicleKey (PK)",
    "vehicle_id",
    "vehicle_type",
    "driver_influence",
    "alcohol",
    "alcohol_offender"
], COLOR_DIM)

table("DimPerson", [
    "PersonKey (PK)",
    "gender",
    "age",
    "person_role",
    "driver_condition",
    "fault"
], COLOR_DIM)

table("DimWeatherCondition", [
    "WeatherConditionKey (PK)",
    "weather_conditions",
    "visibility_range",
    "lighting_conditions",
    "road_condition"
], COLOR_DIM)

table("DimWeatherType", [
    "WeatherTypeKey (PK)",
    "weathercode"
], COLOR_DIM)

table("DimRoadSegment", [
    "RoadSegmentKey (PK)",
    "id",
    "ObjectId",
    "GlobalID",
    "Shape__Length",
    "datum_exportu"
], COLOR_SPATIAL)

# =====================================================
# POSITIONING (THE MAGIC PART)
# =====================================================

# Center anchor
with er.subgraph() as s:
    s.attr(rank="same")
    s.node("FactTrafficAccident")

# Left side dimensions
with er.subgraph() as s:
    s.attr(rank="same")
    s.node("DimVehicle")
    s.node("DimPerson")

# Top dimensions
with er.subgraph() as s:
    s.attr(rank="same")
    s.node("DimTime")
    s.node("DimWeatherCondition")

# Right side dimensions
with er.subgraph() as s:
    s.attr(rank="same")
    s.node("DimLocation")

# Bottom / secondary star
with er.subgraph() as s:
    s.attr(rank="same")
    s.node("FactWeather")
    s.node("DimWeatherType")

with er.subgraph() as s:
    s.attr(rank="same")
    s.node("FactTrafficIntensity")
    s.node("DimRoadSegment")

# =====================================================
# RELATIONSHIPS (REAL + INVISIBLE ANCHORS)
# =====================================================

# Core star
er.edge("DimTime", "FactTrafficAccident")
er.edge("DimLocation", "FactTrafficAccident")
er.edge("DimVehicle", "FactTrafficAccident")
er.edge("DimPerson", "FactTrafficAccident")
er.edge("DimWeatherCondition", "FactTrafficAccident")

# Weather star
er.edge("DimTime", "FactWeather")
er.edge("DimWeatherType", "FactWeather")

# Traffic intensity star
er.edge("DimTime", "FactTrafficIntensity")
er.edge("DimRoadSegment", "FactTrafficIntensity")

# Invisible edges to HOLD layout (critical)
er.edge("FactTrafficAccident", "FactWeather", style="invis")
er.edge("FactTrafficAccident", "FactTrafficIntensity", style="invis")

# =====================================================
# RENDER
# =====================================================
er.render("traffic_dw_erd_true_star", cleanup=True)

