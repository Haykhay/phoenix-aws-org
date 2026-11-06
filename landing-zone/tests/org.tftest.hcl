mock_provider "aws" {}

run "org_has_all_features_and_scp" {
  command = plan

  assert {
    condition     = aws_organizations_organization.this.feature_set == "ALL"
    error_message = "organization must enable ALL features"
  }

  assert {
    condition     = contains(aws_organizations_organization.this.enabled_policy_types, "SERVICE_CONTROL_POLICY")
    error_message = "SCP policy type must be enabled on the org"
  }
}

run "core_accounts_present" {
  command = plan

  assert {
    condition = alltrue([
      aws_organizations_account.log_archive.name == "Log Archive",
      aws_organizations_account.audit.name == "Audit",
      aws_organizations_account.aft_management.name == "AFT Management",
    ])
    error_message = "the three core accounts must be defined"
  }
}
