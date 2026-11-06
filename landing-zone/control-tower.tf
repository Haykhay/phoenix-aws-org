# The Control Tower landing zone, as code. Stands up governance over the org
# and creates the foundational Security OU (Log Archive + Audit) from the
# manifest. Live standup takes ~30-60 min; the definition is verified offline.

locals {
  lz_manifest = {
    governedRegions = var.governed_regions
    organizationStructure = {
      security = { name = var.security_ou_name }
      sandbox  = { name = var.sandbox_ou_name }
    }
    centralizedLogging = {
      accountId = aws_organizations_account.log_archive.id
      configurations = {
        loggingBucket       = { retentionDays = 365 }
        accessLoggingBucket = { retentionDays = 3650 }
      }
      enabled = true
    }
    securityRoles = {
      accountId = aws_organizations_account.audit.id
    }
    accessManagement = {
      enabled = true
    }
  }
}

resource "aws_controltower_landing_zone" "this" {
  version       = var.landing_zone_version
  manifest_json = jsonencode(local.lz_manifest)

  lifecycle {
    prevent_destroy = true
  }
}
