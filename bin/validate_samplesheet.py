#!/usr/bin/env python3
"""Validate a SAGFlow CSV samplesheet without modifying source data."""

from __future__ import annotations

import argparse
import csv
import sys
from pathlib import Path

REQUIRED = ("sample_id", "dataset", "barcode", "r1", "r2")


def validate(path: Path, check_files: bool = True) -> list[str]:
    errors: list[str] = []
    with path.open(newline="", encoding="utf-8-sig") as handle:
        reader = csv.DictReader(handle)
        fields = reader.fieldnames or []
        missing = [column for column in REQUIRED if column not in fields]
        if missing:
            return [f"missing required columns: {', '.join(missing)}"]

        seen: set[str] = set()
        row_count = 0
        for line_number, row in enumerate(reader, start=2):
            row_count += 1
            for column in REQUIRED:
                if not (row.get(column) or "").strip():
                    errors.append(f"line {line_number}: empty {column}")

            sample_id = (row.get("sample_id") or "").strip()
            if sample_id in seen:
                errors.append(f"line {line_number}: duplicate sample_id {sample_id}")
            seen.add(sample_id)

            if check_files:
                for column in ("r1", "r2"):
                    value = (row.get(column) or "").strip()
                    if value and not Path(value).is_file():
                        errors.append(f"line {line_number}: {column} file not found: {value}")

        if row_count == 0:
            errors.append("samplesheet contains no data rows")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--skip-file-check", action="store_true")
    args = parser.parse_args()

    if not args.input.is_file():
        print(f"ERROR: samplesheet not found: {args.input}", file=sys.stderr)
        return 2
    errors = validate(args.input, check_files=not args.skip_file_check)
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print(f"PASS: {args.input}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
