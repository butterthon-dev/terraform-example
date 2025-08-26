locals {
  common_name = var.service_name

  container_definitions_with_logging = [
    for container_definition in var.container_definitions : merge(
      container_definition,
      {
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.main.name
            awslogs-region        = var.region
            awslogs-stream-prefix = "ecs"
          }
        }
      }
    )
  ]
}

################################################################################
# タスク実行ロール
################################################################################
resource "aws_iam_role" "task_execution_role" {
  count = var.create_task_execution_role ? 1 : 0

  name = "${local.common_name}-role-${var.ecs_service_name}-task-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.task_execution_role_tags,
    { Name = "${local.common_name}-role-${var.ecs_service_name}-task-exec" }
  )
}

resource "aws_iam_policy" "task_execution_role" {
  count = var.create_task_execution_role ? 1 : 0

  name   = "${local.common_name}-policy-${var.ecs_service_name}-task-exec"
  policy = jsonencode(var.task_execution_role_policy)
  # policy = jsonencode(merge(
  #   var.task_execution_role_policy,
  #   {
  #     Statement = concat(
  #       var.task_execution_role_policy.Statement,
  #       [{
  #         Effect = "Allow"
  #         Action = [
  #           "kms:Encrypt",
  #           "kms:Decrypt",
  #           "kms:GenerateDataKey*",
  #           "kms:DescribeKey",
  #         ]
  #         Resource = [aws_kms_key.main.arn]
  #       }]
  #     )
  #   }
  # ))

  tags = merge(
    var.task_execution_role_policy_tags,
    { Name = "${local.common_name}-policy-${var.ecs_service_name}-task-exec" }
  )

  # depends_on = [ aws_kms_key.main ]
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  count = var.create_task_execution_role ? 1 : 0

  role       = aws_iam_role.task_execution_role[0].name
  policy_arn = aws_iam_policy.task_execution_role[0].arn
}


################################################################################
# タスクロール
################################################################################
resource "aws_iam_role" "task_role" {
  count = var.create_task_role ? 1 : 0

  name = "${local.common_name}-role-${var.ecs_service_name}-task"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.task_role_tags,
    { Name = "${local.common_name}-role-${var.ecs_service_name}-task" }
  )
}

resource "aws_iam_policy" "task_role" {
  count = var.create_task_role && var.task_role_policy != null ? 1 : 0

  name   = "${local.common_name}-policy-${var.ecs_service_name}-task"
  policy = jsonencode(var.task_role_policy)

  tags = merge(
    var.task_role_policy_tags,
    { Name = "${local.common_name}-policy-${var.ecs_service_name}-task" }
  )
}

resource "aws_iam_role_policy_attachment" "task_role" {
  count = var.create_task_role && var.task_role_policy != null ? 1 : 0

  role       = aws_iam_role.task_role[0].name
  policy_arn = aws_iam_policy.task_role[0].arn
}


################################################################################
# セキュリティグループ
################################################################################

resource "aws_security_group" "main" {
  name        = "${local.common_name}-sg-${var.ecs_service_name}-ecs"
  description = var.sg_description
  vpc_id      = var.vpc_id

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      security_groups = try(egress.value.security_group_ids, null)
      cidr_blocks     = try(egress.value.cidr_blocks, null)
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
    }
  }

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      security_groups = try(ingress.value.security_group_ids, null)
      cidr_blocks     = try(ingress.value.cidr_blocks, null)
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
    }
  }

  tags = merge(
    var.security_group_tags,
    { Name = "${local.common_name}-sg-${var.ecs_service_name}-ecs" }
  )
}


################################################################################
# ECS
################################################################################

# # CloudWatchロググループ
# resource "aws_kms_key" "main" {
#   description             = "KMS key for ECS Service log encryption"
#   deletion_window_in_days = 7
#   enable_key_rotation     = true

#   tags = {
#     Name = "${local.common_name}-${var.ecs_service_name}"
#   }
# }

resource "aws_cloudwatch_log_group" "main" {
  name       = "/aws/ecs/${var.ecs_cluster_name}/${var.ecs_service_name}"
  # kms_key_id = aws_kms_key.main.arn
  tags       = var.cloudwatch_log_group_tags
}

# Service Discovery
resource "aws_service_discovery_service" "main" {
  count = var.enabled_service_discovery ? 1 : 0

  name = var.service_discovery_name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# # ECSクラスター
# data "aws_ecs_cluster" "main" {
#   cluster_name = var.ecs_cluster_name
# }

# ECSタスク定義
resource "aws_ecs_task_definition" "main" {
  family                   = "${local.common_name}-taskdef-${var.ecs_service_name}"
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.create_task_execution_role ? aws_iam_role.task_execution_role[0].arn : var.task_execution_role_arn
  task_role_arn            = var.create_task_role ? aws_iam_role.task_role[0].arn : var.task_role_arn
  container_definitions    = jsonencode(local.container_definitions_with_logging)

  tags = merge(
    var.ecs_task_definition_tags,
    { Name = "${local.common_name}-taskdef-${var.ecs_service_name}" }
  )
}

# ECSサービス
resource "aws_ecs_service" "main" {
  name                               = "${local.common_name}-${var.ecs_service_name}"
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  platform_version                   = var.platform_version
  scheduling_strategy                = var.scheduling_strategy
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  enable_execute_command             = var.enable_execute_command

  dynamic "service_registries" {
    for_each = var.enabled_service_discovery ? [aws_service_discovery_service.main[0]] : []
    content {
      registry_arn = service_registries.value.arn
    }
  }

  dynamic "service_connect_configuration" {
    for_each = var.service_connect_configuration != null ? [var.service_connect_configuration] : []
    content {
      enabled = service_connect_configuration.value.enabled
      dynamic "service" {
        for_each = var.service_connect_configuration.service != null ? [var.service_connect_configuration.service] : []
        content {
          dynamic "client_alias" {
            for_each = service.value.client_alias != null ? [service.value.client_alias] : []
            content {
              dns_name = client_alias.value.dns_name
              port     = client_alias.value.port
            }
          }
          discovery_name        = service.value.discovery_name
          ingress_port_override = service.value.ingress_port_override
          port_name             = service.value.port_name
        }
      }
    }
  }

  dynamic "network_configuration" {
    for_each = var.network_configuration != null ? [var.network_configuration] : []
    content {
      subnets = network_configuration.value.subnet_ids
      security_groups = concat(
        [aws_security_group.main.id],
        var.additional_security_group_ids
      )
      assign_public_ip = network_configuration.value.assign_public_ip
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer != null ? [var.load_balancer] : []
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "deployment_controller" {
    for_each = var.deployment_controller != null ? [var.deployment_controller] : []
    content {
      type = deployment_controller.value.type
    }
  }

  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_circuit_breaker != null ? [var.deployment_circuit_breaker] : []
    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  tags = merge(
    var.ecs_service_tags,
    { Name = "${local.common_name}-${var.ecs_service_name}" }
  )
}
