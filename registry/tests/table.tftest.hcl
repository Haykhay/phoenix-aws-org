mock_provider "aws" {}

run "registry_keyed_by_group" {
  command = plan

  assert {
    condition     = aws_dynamodb_table.registry.hash_key == "group"
    error_message = "registry must be partitioned by group"
  }

  assert {
    condition     = aws_dynamodb_table.registry.billing_mode == "PAY_PER_REQUEST"
    error_message = "registry should be on-demand billed"
  }
}
