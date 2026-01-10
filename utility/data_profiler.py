import pandas as pd
import numpy as np
from pathlib import Path

DATA_DIR = Path(".")


# =========================================================
# REPORTS
# =========================================================

class Overview:
    @staticmethod
    def show(df, name):
        print(f"\n📊 {name} — Overview")
        print(f"Rows: {df.shape[0]} | Columns: {df.shape[1]}")
        print("Columns:", list(df.columns))


class Schema:
    @staticmethod
    def show(df, name):
        print(f"\n🧬 {name} — Schema")
        print(pd.DataFrame({
            "dtype": df.dtypes,
            "non_null": df.notnull().sum(),
            "nulls": df.isnull().sum()
        }))


class MissingData:
    @staticmethod
    def show(df, name):
        print(f"\n🚨 {name} — Missing Data")

        nulls = df.isnull().sum()
        pct = (nulls / len(df) * 100).round(2)

        report = pd.DataFrame({
            "nulls": nulls,
            "percent": pct
        }).query("nulls > 0")

        print(report if not report.empty else "No missing values")


class Statistics:
    @staticmethod
    def show(df, name):
        print(f"\n📈 {name} — Statistics")
        num = df.select_dtypes(include="number")
        print(num.describe().T if not num.empty else "No numeric columns")


class Memory:
    @staticmethod
    def show(df, name):
        mem = df.memory_usage(deep=True).sum() / 1024
        print(f"\n💾 {name} — Memory: {mem:.2f} KB")


class Quality:
    @staticmethod
    def show(df, name):
        print(f"\n🧪 {name} — Quality")
        print("Duplicate rows:", df.duplicated().sum())


class MixedTypes:
    @staticmethod
    def show(df, name):
        print(f"\n⚠️ {name} — Mixed Type Columns")
        for col in df.columns:
            types = df[col].dropna().map(type).nunique()
            if types > 1:
                print(f"{col}: {types} data types detected")


class InvalidTime:
    @staticmethod
    def show(df, name):
        if "time" not in df.columns:
            return

        print(f"\n⏰ {name} — Invalid HHMM Time")

        # Safe numeric coercion
        time_num = pd.to_numeric(df["time"], errors="coerce")

        invalid_mask = (
            time_num.isna() |
            (time_num < 0) |
            (time_num > 2359) |
            (time_num % 100 > 59)
        )

        invalid = df.loc[invalid_mask, "time"]

        print(f"Invalid rows: {len(invalid)}")

        if not invalid.empty:
            print("\nTop invalid values:")
            print(invalid.value_counts().head(10))


class NumericRange:
    @staticmethod
    def show(df, name):
        print(f"\n📏 {name} — Numeric Range Issues")
        for col in df.select_dtypes(include="number"):
            min_v, max_v = df[col].min(), df[col].max()
            if min_v < 0:
                print(f"{col}: negative values (min={min_v})")
            if max_v > 10_000:
                print(f"{col}: suspiciously large values (max={max_v})")


class Outliers:
    @staticmethod
    def show(df, name):
        print(f"\n📊 {name} — Outliers (IQR)")
        for col in df.select_dtypes(include="number"):
            q1, q3 = df[col].quantile([0.25, 0.75])
            iqr = q3 - q1
            outliers = df[
                (df[col] < q1 - 1.5 * iqr) |
                (df[col] > q3 + 1.5 * iqr)
            ]
            if len(outliers) > 0:
                print(f"{col}: {len(outliers)} outliers")


class CategoryVariants:
    @staticmethod
    def show(df, name):
        print(f"\n🧾 {name} — Categorical Variants")
        for col in df.select_dtypes(include="object"):
            uniques = df[col].dropna().unique()
            if 1 < len(uniques) <= 15:
                print(f"\n{col}:")
                print(sorted(map(str, uniques)))


class Sample:
    @staticmethod
    def show(df, name):
        print(f"\n👀 {name} — Sample")
        print(df.head())


# =========================================================
# REPORT REGISTRY
# =========================================================

REPORTS = {
    "1": Overview,
    "2": Schema,
    "3": MissingData,
    "4": Statistics,
    "5": Memory,
    "6": Quality,
    "7": MixedTypes,
    "8": InvalidTime,
    "9": NumericRange,
    "10": Outliers,
    "11": CategoryVariants,
    "12": Sample
}


# =========================================================
# INTERFACE
# =========================================================

def menu():
    print(
        "\nCommands:\n"
        " 1 overview      2 schema        3 missing\n"
        " 4 stats         5 memory        6 duplicates\n"
        " 7 mixed types   8 invalid time  9 numeric range\n"
        "10 outliers     11 categories   12 sample\n"
        " a all           q quit"
    )


def main():
    datasets = {}

    for file in DATA_DIR.glob("*.csv"):
        df = pd.read_csv(file, low_memory=False)
        datasets[file.stem] = df

    if not datasets:
        print("❌ No CSV files found")
        return

    print("\n📂 Loaded datasets (sorted by rows):")
    for name, df in sorted(datasets.items(), key=lambda x: len(x[1])):
        print(f" {name}: {len(df)} rows")

    while True:
        menu()
        cmd = input("\n> ").strip().lower()

        if cmd in {"q", "quit", "exit"}:
            print("Exiting. Bye 👋")
            break

        for name, df in sorted(datasets.items(), key=lambda x: len(x[1])):
            if cmd == "a":
                for key in sorted(REPORTS, key=lambda x: int(x)):
                    REPORTS[key].show(df, name)
            elif cmd in REPORTS:
                REPORTS[cmd].show(df, name)
            else:
                print("Unknown command")
                break


if __name__ == "__main__":
    main()

