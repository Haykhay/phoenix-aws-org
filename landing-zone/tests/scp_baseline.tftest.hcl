mock_provider "aws" {}

run "denies_core_guardrails" {
  command = plan

  assert {
    condition = alltrue([for sid in [
      "DenyLeavingOrganization", "DenyRootUserActivity", "DenyCloudTrailTampering",
      "DenyConfigTampering", "DenyGuardDutyTampering", "DenySecurityHubTampering",
      "DenyMacieTampering", "DenyAccessAnalyzerTampering", "DenyInspectorTampering",
      "DenyDetectiveTampering", "DenyBackupTampering", "DenyS3BlockPublicAccessTampering",
      "DenyDisablingEbsDefaultEncryption"
    ] : strcontains(aws_organizations_policy.baseline[0].content, sid)])
    error_message = "baseline SCP is missing a required Deny statement"
  }
}

run "targets_must_be_declared" {
  command = plan

  variables {
    scp_target_ou_keys = ["workloads/production", "not-an-ou"]
  }

  expect_failures = [aws_organizations_policy.baseline[0]]
}
