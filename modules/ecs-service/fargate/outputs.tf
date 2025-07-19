output "service_id" {
  value = aws_ecs_service.main.id
}

output "service_name" {
  value = aws_ecs_service.main.name
}

output "task_execution_role_arn" {
  value = try(aws_iam_role.task_execution_role[0].arn, var.task_execution_role_arn)
}

output "task_role_arn" {
  value = try(aws_iam_role.task_role[0].arn, var.task_role_arn)
}

output "attached_security_group_id" {
  value = aws_security_group.main.id
}
