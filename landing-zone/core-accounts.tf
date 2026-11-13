# Core accounts the landing zone depends on. Control Tower references the Log
# Archive and Audit accounts in its manifest; AFT runs from its own account.

resource "aws_organizations_account" "log_archive" {
  name              = "Log Archive"
  email             = var.core_account_emails.log_archive
  parent_id         = local.org_root_id
  close_on_deletion = false

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [role_name]
  }
}

resource "aws_organizations_account" "audit" {
  name              = "Audit"
  email             = var.core_account_emails.audit
  parent_id         = local.org_root_id
  close_on_deletion = false

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [role_name]
  }
}

resource "aws_organizations_account" "aft_management" {
  name              = "AFT Management"
  email             = var.core_account_emails.aft_management
  parent_id         = local.org_root_id
  close_on_deletion = false

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [role_name]
  }
}
