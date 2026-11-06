output "declared_ou_paths" {
  description = "Every OU path declared in ous.yaml (pure; offline-testable)."
  value       = local.declared_ou_paths
}

output "ou_ids" {
  description = "Declared OU path -> live Control Tower-managed OU id. Empty under mocks."
  value       = local.ou_ids
}
