import requests
import pandas as pd

# --------------------- CONFIG ---------------------
LAT, LON = 49.1951, 16.6068   # Brno city center coordinates

START = "2017-01-01"
END   = "2024-12-31"

# Key weather variables for analysis and DW
VARIABLES = [
    "temperature_2m",
    "relativehumidity_2m",
    "dewpoint_2m",
    "apparent_temperature",
    "precipitation",
    "rain",
    "snowfall",
    "snow_depth",
    "weathercode",
    "windspeed_10m",
    "cloudcover",
    "pressure_msl"
]

TIMEZONE = "Europe/Prague"
OUTFILE = "brno_weather_2017_2023.csv"

# ------------------ API REQUEST -------------------
url = (
    "https://archive-api.open-meteo.com/v1/archive"
    f"?latitude={LAT}&longitude={LON}"
    f"&start_date={START}&end_date={END}"
    f"&hourly={','.join(VARIABLES)}"
    f"&timezone={TIMEZONE}"
)

print("Requesting weather data...")
response = requests.get(url)
response.raise_for_status()

data = response.json()

# ------------------ CONVERT TO DATAFRAME -------------------
df = pd.DataFrame(data["hourly"])
df["time"] = pd.to_datetime(df["time"])
df = df.set_index("time").sort_index()

# --------------------- SAVE ------------------------
df.to_csv(OUTFILE)
print(f"Saved hourly Brno weather (2017–2023) to: {OUTFILE}")
print("Rows:", len(df))
print("Columns:", len(df.columns))

