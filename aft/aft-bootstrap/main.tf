# AFT (Account Factory for Terraform) deployment, stood up once in the
# AFT-management account. Thereafter, committing an account request drives
# Control Tower to vend the account and run the phoenix-baseline customization.
#
# A full `terraform test` over this module is impractical (it is large and
# multi-account); it is verified by `terraform validate` + tflint + checkov.
module "aft" {
  source  = "aws-ia/control_tower_account_factory/aws"
  version = "~> 1.14"

  # Account wiring — ids come from the landing-zone outputs.
  ct_management_account_id    = var.ct_management_account_id
  log_archive_account_id      = var.log_archive_account_id
  audit_account_id            = var.audit_account_id
  aft_management_account_id   = var.aft_management_account_id
  ct_home_region              = var.ct_home_region
  tf_backend_secondary_region = var.tf_backend_secondary_region

  # VCS wiring (GitHub) — the AFT repos live in this repository.
  vcs_provider                                  = "github"
  account_request_repo_name                     = var.account_request_repo_name
  global_customizations_repo_name               = var.global_customizations_repo_name
  account_customizations_repo_name              = var.account_customizations_repo_name
  account_provisioning_customizations_repo_name = var.account_provisioning_customizations_repo_name

  # Keep the footprint lean for the series.
  aft_feature_cloudtrail_data_events      = false
  aft_feature_enterprise_support          = false
  aft_feature_delete_default_vpcs_enabled = true
}
