terraform {
  # Real bucket/key/region supplied at `terraform init` time.
  # S3-native state locking (no DynamoDB lock table).
  backend "s3" {
    use_lockfile = true
  }
}
