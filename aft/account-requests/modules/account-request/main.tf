# Validates and shapes one account request. In the live AFT repo these feed the
# AFT `aws-account-request` module; here the module is the offline-testable
# contract. `ou` is validated against the landing-zone OU source of truth.

locals {
  ous = yamldecode(file("${path.module}/../../../../landing-zone/ous.yaml")).organizational_units
  allowed_ou_paths = concat(
    keys(local.ous),
    flatten([for parent, cfg in local.ous : [for c in try(cfg.children, []) : "${parent}/${c}"]]),
  )
}

resource "terraform_data" "validate" {
  input = var.ou

  lifecycle {
    precondition {
      condition     = contains(local.allowed_ou_paths, var.ou)
      error_message = "ou '${var.ou}' is not a declared OU path (see landing-zone/ous.yaml)."
    }
  }
}

output "request" {
  description = "The validated account request (no account_id — Control Tower assigns it)."
  value = {
    group        = var.group
    email        = var.email
    ou           = var.ou
    organisation = var.organisation
    base_domain  = var.base_domain
    apps_repo    = var.apps_repo
  }
  depends_on = [terraform_data.validate]
}
