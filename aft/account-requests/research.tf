# Example account request — one module block per group account.
# In the live AFT repo these values feed the AFT `aws-account-request` module;
# offline, ./modules/account-request validates and shapes the request.
# No account_id here: Control Tower assigns it, and CI writes it to the registry.
module "research" {
  source = "./modules/account-request"

  group        = "research"
  email        = "aws+research@example.com"
  ou           = "sandbox"
  organisation = "acme"
  base_domain  = "example.com"
  apps_repo    = "git@github.com:acme/phoenix-apps.git"
}
