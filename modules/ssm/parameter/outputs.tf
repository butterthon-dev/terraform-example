output "id" {
  description = "SSMパラメータのID"
  value       = aws_ssm_parameter.main.id
}

output "name" {
  description = "SSMパラメータの名前"
  value       = aws_ssm_parameter.main.name
}

output "arn" {
  description = "SSMパラメータのARN"
  value       = aws_ssm_parameter.main.arn
}
