import json
import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from upsert import build_item  # noqa: E402

FIXTURES = pathlib.Path(__file__).parent / "fixtures"


class BuildItemTest(unittest.TestCase):
    def test_build_item_matches_golden(self):
        aft_output = json.loads((FIXTURES / "aft-output.json").read_text())
        request = {
            "group": "research",
            "organisation": "acme",
            "ou": "sandbox",
            "base_domain": "example.com",
            "apps_repo": "git@github.com:acme/phoenix-apps.git",
            "management_account_id": "444444444444",
            "state_region": "eu-west-1",
        }

        item = build_item(aft_output, request)

        golden = json.loads((FIXTURES / "accounts.golden.json").read_text())
        self.assertEqual(item, golden)

    def test_build_item_is_keyed_by_group(self):
        aft_output = {"account_id": "222222222222", "state_bucket": "acme-tfstate-222222222222"}
        request = {
            "group": "payments",
            "organisation": "acme",
            "ou": "workloads/production",
            "base_domain": "example.com",
            "apps_repo": "https://github.com/acme/phoenix-apps.git",
            "management_account_id": "444444444444",
            "state_region": "eu-west-1",
        }

        item = build_item(aft_output, request)

        self.assertEqual(item["group"], "payments")
        self.assertEqual(item["account_id"], "222222222222")
        self.assertEqual(item["status"], "ACTIVE")


if __name__ == "__main__":
    unittest.main()
