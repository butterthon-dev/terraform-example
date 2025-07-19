output "replication_group_id" {
  description = "Elasticache cluster ID"
  value       = aws_elasticache_replication_group.main.id
}

output "primary_endpoint" {
  description = "Elasticache cluster members"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Elasticache cluster members"
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "port" {
  description = "Elasticache port"
  value       = var.port
}
