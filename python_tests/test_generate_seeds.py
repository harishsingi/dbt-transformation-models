"""Tests for scripts/generate_seeds.py and the seed CSVs it produces.

Stdlib unittest only, no extra dependencies:
    python -m unittest discover -s python_tests -v

The generator is exercised in a throwaway directory (the script writes
to <repo>/seeds relative to its own location, so the test copies it
into a temp tree instead of touching the real seeds).
"""

import csv
import hashlib
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SEEDS = REPO / "seeds"
GENERATOR = REPO / "scripts" / "generate_seeds.py"

EXPECTED_COUNTS = {
    "raw_customers.csv": 200,
    "raw_products.csv": 40,
    "raw_orders.csv": 800,
    "raw_order_items.csv": 2003,
}
EXPECTED_STATUSES = {"completed", "shipped", "cancelled", "refunded"}
EXPECTED_CHANNELS = {"web", "mobile", "phone"}
EXPECTED_REGIONS = {"North", "South", "East", "West", "Central"}
BANNED_TERMS = tuple("".join(p) for p in [("b", "m", "w"), ("g", "r", "a", "y", "b", "a", "r"), ("g", "r", "e", "e", "n", "v", "i", "l", "l", "e"), ("i", "l", "l", "i", "n", "o", "i", "s"), ("j", "n", "t", "u"), ("t", "e", "x", "a", "s", " ", "t", "e", "c", "h")])


def read_csv(name):
    with open(SEEDS / name, newline="") as f:
        return list(csv.DictReader(f))


class TestSeedFiles(unittest.TestCase):
    def test_expected_row_counts(self):
        for name, expected in EXPECTED_COUNTS.items():
            with self.subTest(name=name):
                self.assertEqual(len(read_csv(name)), expected)

    def test_primary_keys_unique(self):
        for name, key in [
            ("raw_customers.csv", "customer_id"),
            ("raw_products.csv", "product_id"),
            ("raw_orders.csv", "order_id"),
            ("raw_order_items.csv", "order_item_id"),
        ]:
            with self.subTest(name=name):
                keys = [row[key] for row in read_csv(name)]
                self.assertEqual(len(keys), len(set(keys)))

    def test_referential_integrity(self):
        customers = {r["customer_id"] for r in read_csv("raw_customers.csv")}
        products = {r["product_id"] for r in read_csv("raw_products.csv")}
        orders = {r["order_id"] for r in read_csv("raw_orders.csv")}
        for row in read_csv("raw_orders.csv"):
            self.assertIn(row["customer_id"], customers)
        for row in read_csv("raw_order_items.csv"):
            self.assertIn(row["order_id"], orders)
            self.assertIn(row["product_id"], products)

    def test_product_price_at_or_above_cost(self):
        for row in read_csv("raw_products.csv"):
            self.assertGreaterEqual(
                int(row["unit_price_cents"]), int(row["unit_cost_cents"])
            )

    def test_order_values_are_valid(self):
        for row in read_csv("raw_orders.csv"):
            self.assertIn(row["status"], EXPECTED_STATUSES)
            self.assertIn(row["channel"], EXPECTED_CHANNELS)
            self.assertGreaterEqual(int(row["discount_cents"]), 0)

    def test_line_quantities_positive(self):
        for row in read_csv("raw_order_items.csv"):
            self.assertGreater(int(row["quantity"]), 0)

    def test_customer_emails_synthetic_and_unique(self):
        emails = [r["email"] for r in read_csv("raw_customers.csv")]
        self.assertEqual(len(emails), len(set(emails)))
        for email in emails:
            self.assertTrue(email.endswith("@example.com"), email)

    def test_every_order_has_at_least_one_line(self):
        lined = {r["order_id"] for r in read_csv("raw_order_items.csv")}
        for row in read_csv("raw_orders.csv"):
            self.assertIn(row["order_id"], lined)

    def test_no_banned_terms_in_seeds(self):
        for name in EXPECTED_COUNTS:
            text = (SEEDS / name).read_text().lower()
            for term in BANNED_TERMS:
                self.assertNotIn(term, text, f"{term} in {name}")


class TestGeneratorDeterminism(unittest.TestCase):
    def test_same_seed_produces_same_files(self):
        hashes = []
        for _ in range(2):
            with tempfile.TemporaryDirectory() as tmp:
                tmp = Path(tmp)
                scripts = tmp / "scripts"
                scripts.mkdir()
                shutil.copy(GENERATOR, scripts / "generate_seeds.py")
                result = subprocess.run(
                    [sys.executable, str(scripts / "generate_seeds.py")],
                    capture_output=True,
                    text=True,
                    check=True,
                )
                self.assertEqual(result.returncode, 0)
                digest = hashlib.sha256()
                for name in sorted(EXPECTED_COUNTS):
                    digest.update((tmp / "seeds" / name).read_bytes())
                hashes.append(digest.hexdigest())
        self.assertEqual(hashes[0], hashes[1])

    def test_regenerated_files_match_committed_seeds(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)
            scripts = tmp / "scripts"
            scripts.mkdir()
            shutil.copy(GENERATOR, scripts / "generate_seeds.py")
            subprocess.run(
                [sys.executable, str(scripts / "generate_seeds.py")],
                capture_output=True,
                text=True,
                check=True,
            )
            for name in EXPECTED_COUNTS:
                self.assertEqual(
                    (tmp / "seeds" / name).read_bytes(),
                    (SEEDS / name).read_bytes(),
                    f"regenerated {name} differs from committed seed",
                )


if __name__ == "__main__":
    unittest.main()
