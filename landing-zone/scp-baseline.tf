# Baseline SCP: an ADDITIONAL policy layered on the Control Tower-managed OUs
# (de-branded from the production reference). Attached by resolved OU id.

locals {
  scp_targets = coalesce(var.scp_target_ou_keys, local.declared_ou_paths)
}

resource "aws_organizations_policy" "baseline" {
  # Floci's Organizations CreatePolicy rejects the freshly-created org
  # (AWSOrganizationsNotInUseException), so the SCP is skipped on Floci. Its
  # content is covered by terraform test and its enforcement is live-only.
  # TODO: drop this gate once Floci fixes CreatePolicy membership.
  count = var.floci ? 0 : 1

  name        = "security-baseline"
  description = "Baseline guardrails layered on Control Tower-managed OUs."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeavingOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      },
      {
        Sid       = "DenyRootUserActivity"
        Effect    = "Deny"
        Action    = "*"
        Resource  = "*"
        Condition = { StringLike = { "aws:PrincipalArn" = "arn:aws:iam::*:root" } }
      },
      {
        Sid      = "DenyCloudTrailTampering"
        Effect   = "Deny"
        Action   = ["cloudtrail:DeleteTrail", "cloudtrail:PutEventSelectors", "cloudtrail:StopLogging", "cloudtrail:UpdateTrail"]
        Resource = "*"
      },
      {
        Sid      = "DenyConfigTampering"
        Effect   = "Deny"
        Action   = ["config:DeleteConfigurationRecorder", "config:DeleteDeliveryChannel", "config:DeleteRetentionConfiguration", "config:StopConfigurationRecorder"]
        Resource = "*"
      },
      {
        Sid      = "DenyGuardDutyTampering"
        Effect   = "Deny"
        Action   = ["guardduty:DeleteDetector", "guardduty:DisassociateFromMasterAccount", "guardduty:DisassociateMembers", "guardduty:StopMonitoringMembers", "guardduty:UpdateDetector"]
        Resource = "*"
      },
      {
        Sid      = "DenySecurityHubTampering"
        Effect   = "Deny"
        Action   = ["securityhub:BatchDisableStandards", "securityhub:DeleteMembers", "securityhub:DisableSecurityHub", "securityhub:DisassociateFromMasterAccount", "securityhub:DisassociateMembers"]
        Resource = "*"
      },
      {
        Sid      = "DenyMacieTampering"
        Effect   = "Deny"
        Action   = ["macie2:DisableMacie", "macie2:DeleteMember", "macie2:DisableOrganizationAdminAccount", "macie2:DisassociateFromAdministratorAccount", "macie2:DisassociateMember"]
        Resource = "*"
      },
      {
        Sid      = "DenyAccessAnalyzerTampering"
        Effect   = "Deny"
        Action   = ["access-analyzer:DeleteAnalyzer", "access-analyzer:DeleteArchiveRule", "access-analyzer:UpdateArchiveRule"]
        Resource = "*"
      },
      {
        Sid      = "DenyInspectorTampering"
        Effect   = "Deny"
        Action   = ["inspector2:Disable", "inspector2:DisableDelegatedAdminAccount", "inspector2:DisassociateMember"]
        Resource = "*"
      },
      {
        Sid      = "DenyDetectiveTampering"
        Effect   = "Deny"
        Action   = ["detective:DeleteGraph", "detective:DeleteMembers", "detective:DisableOrganizationAdminAccount", "detective:DisassociateMembership"]
        Resource = "*"
      },
      {
        Sid      = "DenyBackupTampering"
        Effect   = "Deny"
        Action   = ["backup:DeleteBackupPlan", "backup:DeleteBackupSelection", "backup:DeleteBackupVault", "backup:DeleteBackupVaultAccessPolicy", "backup:DeleteBackupVaultLockConfiguration", "backup:DeleteRecoveryPoint", "backup:PutBackupVaultAccessPolicy", "backup:StopBackupJob", "backup:UpdateBackupPlan"]
        Resource = "*"
      },
      {
        Sid      = "DenyS3BlockPublicAccessTampering"
        Effect   = "Deny"
        Action   = ["s3:DeleteAccountPublicAccessBlock", "s3:DeleteBucketPublicAccessBlock"]
        Resource = "*"
      },
      {
        Sid      = "DenyDisablingEbsDefaultEncryption"
        Effect   = "Deny"
        Action   = "ec2:DisableEbsEncryptionByDefault"
        Resource = "*"
      },
    ]
  })

  lifecycle {
    precondition {
      condition     = length(setsubtract(toset(local.scp_targets), toset(local.declared_ou_paths))) == 0
      error_message = "scp_target_ou_keys contains OU paths not declared in ous.yaml"
    }
  }
}

resource "aws_organizations_policy_attachment" "baseline" {
  for_each  = var.floci ? toset([]) : toset(local.scp_targets)
  policy_id = aws_organizations_policy.baseline[0].id
  target_id = local.ou_ids[each.value]
}
