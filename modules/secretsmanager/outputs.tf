output "secret_arn" {
  description = "SecretsManagerのシークレットARN"
  value       = aws_secretsmanager_secret.main.arn
}

output "secret_name" {
  description = "SecretsManagerのシークレット名"
  value       = aws_secretsmanager_secret.main.name
}
