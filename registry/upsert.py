#!/usr/bin/env python3
"""Upsert the account registry from AFT outputs.

`build_item` is pure and unit-tested; `main` performs the DynamoDB put and is
only exercised live. Keying on `group` makes the upsert idempotent.
"""
import json
import sys


def build_item(aft_output, request):
    """Map AFT outputs + the account request to a registry item (dict)."""
    return {
        "group": request["group"],
        "account_id": aft_output["account_id"],
        "organisation": request["organisation"],
        "state_bucket": aft_output["state_bucket"],
        "state_region": request["state_region"],
        "management_account_id": request["management_account_id"],
        "base_domain": request["base_domain"],
        "apps_repo": request["apps_repo"],
        "ou": request["ou"],
        "status": "ACTIVE",
    }


def main(argv):
    if len(argv) != 4:
        raise SystemExit("usage: upsert.py <aft-output.json> <request.json> <table-name>")
    import boto3  # lazy import so tests can import build_item without boto3

    with open(argv[1]) as fh:
        aft_output = json.load(fh)
    with open(argv[2]) as fh:
        request = json.load(fh)
    table = argv[3]

    item = build_item(aft_output, request)
    boto3.client("dynamodb").put_item(
        TableName=table,
        Item={k: {"S": str(v)} for k, v in item.items()},
    )
    print(f"upserted group={item['group']} account_id={item['account_id']}")


if __name__ == "__main__":
    main(sys.argv)
