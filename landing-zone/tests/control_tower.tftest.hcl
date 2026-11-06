mock_provider "aws" {}

run "manifest_is_well_formed" {
  command = plan

  assert {
    condition     = output.landing_zone_manifest.organizationStructure.security.name == "Security"
    error_message = "landing zone manifest must name the Security OU"
  }

  assert {
    condition     = output.landing_zone_manifest.centralizedLogging.enabled == true
    error_message = "centralized logging must be enabled"
  }

  assert {
    condition     = length(output.landing_zone_manifest.governedRegions) > 0
    error_message = "at least one governed region is required"
  }
}
