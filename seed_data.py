#!/usr/bin/env python3
import argparse
import csv
from pathlib import Path

REQUIRED_COLUMNS = [
    "patient_id",
    "name",
    "age",
    "condition",
    "medication_count",
    "missed_doses_last_7_days",
    "missed_doses_last_30_days",
    "side_effects",
    "previous_adherence_rate",
    "appointment_attendance",
    "risk_label",
]


def validate_header(header):
    return list(header) == REQUIRED_COLUMNS


def validate_existing_target(target: Path):
    with target.open("r", newline="", encoding="utf-8") as src:
        reader = csv.reader(src)
        rows = list(reader)

    if not rows:
        raise ValueError(f"Existing target file is empty: {target.name}")

    if not validate_header(rows[0]):
        raise ValueError(
            f"Existing target file has invalid columns: {target.name}. "
            "Fix the header or reseed with --force."
        )


def seed_data(source: Path, target: Path, force: bool = False):
    if target.exists() and not force:
        validate_existing_target(target)
        print(f"Seed skipped: {target.name} already exists. Use --force to overwrite.")
        return

    if not source.exists():
        raise FileNotFoundError(f"Seed source file not found: {source}")

    with source.open("r", newline="", encoding="utf-8") as src:
        reader = csv.reader(src)
        rows = list(reader)

    if not rows:
        raise ValueError("Seed source is empty.")

    header = rows[0]
    if not validate_header(header):
        raise ValueError("Seed source columns do not match expected dataset schema.")

    with target.open("w", newline="", encoding="utf-8") as out:
        writer = csv.writer(out)
        writer.writerows(rows)

    print(f"Seed complete: {target.name} written with {len(rows) - 1} patient records.")


def main():
    parser = argparse.ArgumentParser(description="Seed local patient dataset for MedAgent.")
    parser.add_argument("--source", default="patients_seed.csv", help="Seed CSV input file")
    parser.add_argument("--target", default="patients.csv", help="Target CSV file")
    parser.add_argument("--force", action="store_true", help="Overwrite existing target")
    args = parser.parse_args()

    seed_data(Path(args.source), Path(args.target), force=args.force)


if __name__ == "__main__":
    main()
