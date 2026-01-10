import psycopg2
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# ==============================
# DATABASE CONFIG
# ==============================
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "brno_traffic",
    "user": "postgres",
    "password": "postgres"
}

# ==============================
# LOAD DATA
# ==============================
def load_data():
    conn = psycopg2.connect(**DB_CONFIG)

    accidents = pd.read_sql("""
        SELECT *
        FROM bi.vw_traffic_accidents
    """, conn)

    weather = pd.read_sql("""
        SELECT *
        FROM bi.vw_weather_hourly
    """, conn)

    traffic = pd.read_sql("""
        SELECT *
        FROM bi.vw_vehicle_traffic_intensity
    """, conn)

    conn.close()
    return accidents, weather, traffic


# ==============================
# ANALYSIS FUNCTIONS
# ==============================
def accidents_over_time(df):
    yearly = df.groupby("year").size()
    print("\n📈 Accidents per year")
    print(yearly)

    yearly.plot(kind="line", marker="o", title="Accidents per Year")
    plt.show()


def hourly_pattern(df):
    hourly = df.groupby("hour").size()
    print("\n⏰ Accidents by hour")
    print(hourly)

    hourly.plot(kind="bar", title="Accidents by Hour")
    plt.show()


def weather_temperature_risk(accidents, weather):
    merged = pd.merge(
        weather,
        accidents,
        on=["full_date", "time_label"],
        how="left"
    )

    merged["temp_bucket"] = (merged["temperature_2m"] // 5) * 5

    stats = (
        merged.groupby("temp_bucket")
        .agg(
            weather_hours=("temperature_2m", "count"),
            accidents=("accident_id", "count")
        )
    )

    stats["accidents_per_hour"] = (
        stats["accidents"] / stats["weather_hours"]
    )

    stats = stats[stats["weather_hours"] > 100]

    print("\n🌡 Accident risk by temperature bucket")
    print(stats)

    sns.lineplot(
        data=stats,
        x=stats.index,
        y="accidents_per_hour",
        marker="o"
    )
    plt.title("Accident Risk vs Temperature")
    plt.xlabel("Temperature (°C)")
    plt.ylabel("Accidents per Hour")
    plt.show()


def rain_vs_no_rain(accidents, weather):
    merged = pd.merge(
        weather,
        accidents,
        on=["full_date", "time_label"],
        how="left"
    )

    merged["rain_flag"] = merged["rain"] > 0

    summary = merged.groupby("rain_flag").agg(
        weather_hours=("rain", "count"),
        accidents=("accident_id", "count")
    )

    summary["accidents_per_hour"] = (
        summary["accidents"] / summary["weather_hours"]
    )

    print("\n🌧 Rain vs No Rain")
    print(summary)

    summary["accidents_per_hour"].plot(
        kind="bar",
        title="Accident Rate: Rain vs No Rain"
    )
    plt.show()


def severity_vs_weather(accidents, weather):
    merged = pd.merge(
        weather,
        accidents,
        on=["full_date", "time_label"],
        how="inner"
    )

    merged["temp_bucket"] = (merged["temperature_2m"] // 5) * 5

    severity = (
        merged.groupby("temp_bucket")
        .agg(
            avg_killed=("killed_persons", "mean"),
            avg_serious=("seriously_injured", "mean")
        )
    )

    print("\n🚑 Accident severity vs temperature")
    print(severity)

    severity.plot(title="Severity vs Temperature")
    plt.show()


def traffic_exposure(accidents, traffic):
    yearly_acc = accidents.groupby("year").size()
    yearly_traffic = traffic.groupby("year")["total_vehicles"].sum()

    exposure = pd.concat(
        [yearly_acc, yearly_traffic], axis=1
    )
    exposure.columns = ["accidents", "vehicles"]

    exposure["accidents_per_10k"] = (
        exposure["accidents"] * 10000 / exposure["vehicles"]
    )

    print("\n🚗 Accidents per 10k vehicles")
    print(exposure)

    exposure["accidents_per_10k"].plot(
        marker="o",
        title="Accidents per 10k Vehicles"
    )
    plt.show()


# ==============================
# MAIN
# ==============================
if __name__ == "__main__":
    accidents, weather, traffic = load_data()

    accidents_over_time(accidents)
    hourly_pattern(accidents)
    weather_temperature_risk(accidents, weather)
    rain_vs_no_rain(accidents, weather)
    severity_vs_weather(accidents, weather)
    traffic_exposure(accidents, traffic)

