terraform {
  # Real bucket/key/region supplied at `terraform init` time.
  backend "s3" {
    use_lockfile = true
  }
}
