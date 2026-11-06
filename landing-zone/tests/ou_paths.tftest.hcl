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

run "creates_the_ou_tree" {
  command = plan

  assert {
    condition     = length(aws_organizations_organizational_unit.root) == 4
    error_message = "expected 4 root OUs (sandbox, shared-services, infrastructure, workloads)"
  }

  assert {
    condition     = aws_organizations_organizational_unit.child["workloads/production"].name == "production"
    error_message = "expected a workloads/production child OU"
  }
}
