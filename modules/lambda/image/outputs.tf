output "lambda_function_arn" {
  description = "Lambda関数のARN"
  value       = aws_lambda_function.main.arn
}

output "lambda_function_name" {
  description = "Lambda関数名"
  value       = aws_lambda_function.main.function_name
}
