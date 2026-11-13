# The account registry: one item per group account, partition key `group`
# (ADR-0002). Durable source of truth; Backstage reads it via an entity
# provider and re-syncs on rebuild.

resource "aws_kms_key" "registry" {
  description             = "Customer-managed key for the account registry table."
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "registry" {
  name          = "alias/${var.table_name}"
  target_key_id = aws_kms_key.registry.key_id
}

resource "aws_dynamodb_table" "registry" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "group"

  attribute {
    name = "group"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.registry.arn
  }

  deletion_protection_enabled = true

  lifecycle {
    prevent_destroy = true
  }
}
