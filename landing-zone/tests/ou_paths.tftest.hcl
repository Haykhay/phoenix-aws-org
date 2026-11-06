mock_provider "aws" {}

run "declares_all_ou_paths" {
  command = plan

  assert {
    condition = toset(output.declared_ou_paths) == toset([
      "sandbox", "shared-services", "infrastructure", "infrastructure/networking",
      "infrastructure/identity", "infrastructure/tooling", "infrastructure/monitoring",
      "infrastructure/security", "workloads", "workloads/nonprod", "workloads/production"
    ])
    error_message = "declared_ou_paths must match ous.yaml exactly"
  }
}
