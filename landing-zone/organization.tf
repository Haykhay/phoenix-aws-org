# The AWS Organizations org itself. Greenfield: this is the root of everything.

resource "aws_organizations_organization" "this" {
  feature_set          = "ALL"
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]

  aws_service_access_principals = [
    "controltower.amazonaws.com",
    "config.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "sso.amazonaws.com",
    "account.amazonaws.com",
  ]

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  # try() keeps the config evaluable under mock providers (offline tests).
  org_root_id = try(aws_organizations_organization.this.roots[0].id, "r-root")
}
