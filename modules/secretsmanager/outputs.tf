output "secret_arn" {
  description = "SecretsManagerのシークレットARN"
  value       = aws_secretsmanager_secret.main.arn
}

output "secret_id" {
  description = "SecretsManagerのシークレットID"
  value       = aws_secretsmanager_secret.main.id
}

output "secret_name" {
  description = "SecretsManagerのシークレット名"
  value       = aws_secretsmanager_secret.main.name
}

output "secret_string" {
  description = "SecretsManagerのシークレット文字列"
  value       = var.create_secret_version ? aws_secretsmanager_secret_version.main[0].secret_string : null
}
