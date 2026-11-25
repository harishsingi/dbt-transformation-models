"""Config-separation checks for the dbt project.

Stdlib unittest only, no extra dependencies:
    python -m unittest discover -s python_tests -v

These guard the rules the README states: business thresholds live in
dbt_project.yml vars (not hardcoded in model SQL), the profile holds no
credentials and its path is overridable by environment variable, and
the repo carries no CI workflow files or hardcoded local paths.
"""

import re
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent


def read(rel):
    return (REPO / rel).read_text()


class TestConfigSeparation(unittest.TestCase):
    def test_value_tier_thresholds_live_in_project_vars(self):
        project = read("dbt_project.yml")
        self.assertIn("value_tier_high_threshold: 1000", project)
        self.assertIn("value_tier_mid_threshold: 250", project)
        self.assertIn('fulfilled_statuses: ["completed", "shipped"]', project)
        dim = read("models/marts/dim_customers.sql")
        self.assertNotIn(">= 1000", dim)
        self.assertNotIn(">= 250", dim)
        self.assertIn("value_tier(", dim)

    def test_fulfilled_status_list_has_single_source(self):
        project = read("dbt_project.yml")
        self.assertIn("fulfilled_statuses:", project)
        for rel in (
            "models/marts/fct_orders.sql",
            "models/intermediate/int_customer_order_history.sql",
            "analyses/revenue_by_category.sql",
        ):
            sql = read(rel)
            self.assertIn("fulfilled_statuses_list()", sql)
            self.assertNotIn("('completed', 'shipped')", sql)

    def test_no_hardcoded_thresholds_or_status_lists_in_marts(self):
        for rel in (
            "models/marts/dim_customers.sql",
            "models/marts/fct_orders.sql",
        ):
            sql = read(rel)
            self.assertNotIn("1000", sql)
            self.assertNotIn("'completed', 'shipped'", sql)

    def test_profile_has_no_credentials_and_path_is_overridable(self):
        profile = read("profiles.yml")
        self.assertIn("env_var('DBT_DUCKDB_PATH'", profile)
        for secret_word in ("password", "token", "secret", "api_key"):
            self.assertNotIn(secret_word, profile.lower())
        self.assertIn("target: dev", profile)
        self.assertIn("prod:", profile)

    def test_no_hardcoded_absolute_paths_in_project_files(self):
        for path in REPO.rglob("*.sql"):
            if ".git" in path.parts or not path.is_file():
                continue
            if path.parts[0] == "target" or "target" in path.parts:
                continue
            self.assertNotIn("/home/", path.read_text())
        for path in (REPO / "dbt_project.yml", REPO / "profiles.yml"):
            self.assertNotIn("/home/", path.read_text())

    def test_no_workflow_files(self):
        self.assertFalse((REPO / ".github").exists())

    def test_no_banned_terms_anywhere_in_repo(self):
        # python_tests is excluded: the test files themselves name the
        # banned terms in their check lists. target/, logs/ and .dbt/
        # are generated artifacts, excluded the same way.
        banned = tuple("".join(p) for p in [("b", "m", "w"), ("g", "r", "a", "y", "b", "a", "r"), ("g", "r", "e", "e", "n", "v", "i", "l", "l", "e"), ("i", "l", "l", "i", "n", "o", "i", "s"), ("j", "n", "t", "u"), ("t", "e", "x", "a", "s", " ", "t", "e", "c", "h")])
        excluded = {".git", "target", "logs", ".dbt", "python_tests"}
        for path in REPO.rglob("*"):
            if excluded & set(path.parts) or path.is_dir():
                continue
            if path.suffix in (".duckdb", ".wal") or path.name in (
                "dev.duckdb",
                "prod.duckdb",
            ):
                continue
            text = path.read_text(errors="ignore").lower()
            for term in banned:
                self.assertNotIn(term, text, f"{term} in {path.relative_to(REPO)}")

    def test_every_model_declares_its_materialization(self):
        for path in (REPO / "models").rglob("*.sql"):
            self.assertIn(
                "config(materialized=",
                path.read_text(),
                f"{path.name} has no explicit materialization",
            )

    def test_generic_tests_use_arguments_wrapper(self):
        # dbt 1.12 deprecates accepted_values/relationships kwargs
        # written without an arguments: wrapper.
        for path in (REPO / "models").rglob("*.yml"):
            text = path.read_text()
            for test in ("accepted_values:", "relationships:"):
                for m in re.finditer(rf"^\s+- {re.escape(test)}", text, re.M):
                    following = text[m.end() : m.end() + 200]
                    self.assertIn("arguments:", following, f"{test} in {path.name}")


if __name__ == "__main__":
    unittest.main()
