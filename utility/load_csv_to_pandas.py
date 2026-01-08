import pandas as pd
from pathlib import Path

DATA_DIR = Path(".")


# ---------- REPORTS ----------

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
            "non_null": df.notnull().sum()
        }))


class MissingData:
    @staticmethod
    def show(df, name):
        print(f"\n🚨 {name} — Missing Data")

        nulls = df.isnull().sum()
        pct = (nulls / len(df) * 100).round(2)

        report = pd.DataFrame({"nulls": nulls, "percent": pct})
        report = report[report["nulls"] > 0]

        print(report if not report.empty else "No missing values")


class Statistics:
    @staticmethod
    def show(df, name):
        print(f"\n📈 {name} — Statistics")

        num = df.select_dtypes(include="number")
        if not num.empty:
            print(num.describe().T)
        else:
            print("No numeric columns")


class Memory:
    @staticmethod
    def show(df, name):
        mem = df.memory_usage(deep=True).sum() / 1024
        print(f"\n💾 {name} — Memory: {mem:.2f} KB")


class Quality:
    @staticmethod
    def show(df, name):
        print(f"\n🧪 {name} — Data Quality")
        print("Duplicates:", df.duplicated().sum())


class Sample:
    @staticmethod
    def show(df, name):
        print(f"\n👀 {name} — Sample")
        print(df.head())


REPORTS = {
    "1": Overview,
    "2": Schema,
    "3": MissingData,
    "4": Statistics,
    "5": Memory,
    "6": Quality,
    "7": Sample
}


# ---------- INTERFACE ----------

def menu():
    print(
        "\nCommands:\n"
        " 1 overview   2 schema   3 missing\n"
        " 4 stats      5 memory   6 quality\n"
        " 7 sample     a all      q quit"
    )


def main():
    datasets = {}

    # Load CSVs and assign to globals
    for file in DATA_DIR.glob("*.csv"):
        name = file.stem
        df = pd.read_csv(file)

        datasets[name] = df
        globals()[name] = df   # ✅ load with same dataset name

    if not datasets:
        print("No CSV files found")
        return

    print("Loaded datasets (sorted by rows ↑):")
    for name, df in sorted(datasets.items(), key=lambda x: len(x[1])):
        print(f" {name} ({len(df)} rows)")

    while True:
        menu()
        cmd = input("\n> ").strip().lower()

        if cmd in {"q", "quit", "exit"}:
            print("Exiting. Bye 👋")
            break

        for name, df in sorted(datasets.items(), key=lambda x: len(x[1])):
            if cmd == "a":
                for key in sorted(REPORTS):
                    REPORTS[key].show(df, name)
            elif cmd in REPORTS:
                REPORTS[cmd].show(df, name)
            else:
                print("Unknown command")
                break


if __name__ == "__main__":
    main()

