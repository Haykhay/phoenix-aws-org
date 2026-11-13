output "table_name" {
  description = "Registry table name."
  value       = aws_dynamodb_table.registry.name
}

output "table_arn" {
  description = "Registry table ARN."
  value       = aws_dynamodb_table.registry.arn
}
