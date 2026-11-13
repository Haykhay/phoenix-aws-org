output "declared_ou_paths" {
  description = "Every OU path declared in ous.yaml."
  value       = local.declared_ou_paths
}

output "ou_ids" {
  description = "OU path -> created OU id, for SCP attachment and AFT placement."
  value       = local.ou_ids
}

output "log_archive_account_id" {
  value = aws_organizations_account.log_archive.id
}

output "audit_account_id" {
  value = aws_organizations_account.audit.id
}

output "aft_management_account_id" {
  value = aws_organizations_account.aft_management.id
}

output "landing_zone_manifest" {
  description = "The Control Tower landing-zone manifest object (static fields are plan-known)."
  value       = local.lz_manifest
}
