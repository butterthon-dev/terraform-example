locals {
  common_name = "${var.env}-${var.service_name}"
}


resource "aws_cloudwatch_log_group" "main" {
  name = "/aws/elasticache/${local.common_name}-elasticache-${var.replication_group_id}"
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${local.common_name}-subnetg-${var.replication_group_id}"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "main" {
  name   = "${local.common_name}-sg-${var.replication_group_id}"
  vpc_id = var.vpc_id

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      security_groups = try(egress.value.security_groups, null)
      cidr_blocks     = try(egress.value.cidr_blocks, null)
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
    }
  }

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      security_groups = try(ingress.value.security_groups, null)
      cidr_blocks     = try(ingress.value.cidr_blocks, null)
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
    }
  }

  tags = {
    Name = "${local.common_name}-sg-${var.replication_group_id}"
  }
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${local.common_name}-elasticache-${var.replication_group_id}"
  description                = var.description
  cluster_mode               = var.cluster_mode
  node_type                  = var.node_type
  engine                     = "valkey"
  parameter_group_name       = var.parameter_group_name
  engine_version             = var.engine_version
  port                       = var.port
  automatic_failover_enabled = var.automatic_failover_enabled
  num_node_groups            = var.num_node_groups
  replicas_per_node_group    = var.replicas_per_node_group
  security_group_ids         = [aws_security_group.main.id]
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  apply_immediately          = var.apply_immediately
  transit_encryption_enabled = var.transit_encryption_enabled

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.main.name
    destination_type = "cloudwatch-logs"
    log_format       = var.slow_log_format
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.main.name
    destination_type = "cloudwatch-logs"
    log_format       = var.engine_log_format
    log_type         = "engine-log"
  }

  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configurations
    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }
}
