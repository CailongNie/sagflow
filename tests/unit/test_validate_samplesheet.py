import csv
import tempfile
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "bin"))
from validate_samplesheet import validate  # noqa: E402


class SamplesheetValidationTests(unittest.TestCase):
    def write_sheet(self, rows):
        directory = tempfile.TemporaryDirectory()
        path = Path(directory.name) / "samples.csv"
        with path.open("x", newline="") as handle:
            writer = csv.DictWriter(
                handle,
                fieldnames=["sample_id", "dataset", "barcode", "r1", "r2"],
            )
            writer.writeheader()
            writer.writerows(rows)
        self.addCleanup(directory.cleanup)
        return path

    def test_valid_minimal_sheet(self):
        sheet = self.write_sheet(
            [{"sample_id": "S1", "dataset": "D1", "barcode": "BC1", "r1": "r1.fq", "r2": "r2.fq"}]
        )
        self.assertEqual(validate(sheet, check_files=False), [])

    def test_duplicate_sample_id(self):
        row = {"sample_id": "S1", "dataset": "D1", "barcode": "BC1", "r1": "r1.fq", "r2": "r2.fq"}
        sheet = self.write_sheet([row, row])
        errors = validate(sheet, check_files=False)
        self.assertTrue(any("duplicate sample_id" in error for error in errors))

    def test_empty_required_value(self):
        sheet = self.write_sheet(
            [{"sample_id": "S1", "dataset": "D1", "barcode": "", "r1": "r1.fq", "r2": "r2.fq"}]
        )
        errors = validate(sheet, check_files=False)
        self.assertTrue(any("empty barcode" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
