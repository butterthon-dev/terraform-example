resource "aws_ssm_parameter" "main" {
  name        = var.name
  description = var.description
  type        = var.type
  value       = var.value
  tags = merge(
    var.tags,
    { Name = var.name }
  )

  lifecycle {
    ignore_changes = [value]
  }
}
