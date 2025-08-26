# ECSクラスター
resource "aws_ecs_cluster" "main" {
  name = var.name

  dynamic "setting" {
    for_each = var.settings
    content {
      name = setting.value.name
      value = setting.value.value
    }
  }

  dynamic "configuration" {
    for_each = var.configuration != null ? [var.configuration] : []
    content {
      dynamic "execute_command_configuration" {
        for_each = configuration.value.execute_command_configuration != null ? [configuration.value.execute_command_configuration] : []
        content {
          logging = execute_command_configuration.value.logging
          dynamic "log_configuration" {
            for_each = execute_command_configuration.value.log_configuration != null ? [execute_command_configuration.value.log_configuration] : []
            content {
              cloud_watch_encryption_enabled = log_configuration.value.cloud_watch_encryption_enabled
              cloud_watch_log_group_name = log_configuration.value.cloud_watch_log_group_name
              s3_bucket_encryption_enabled = log_configuration.value.s3_bucket_encryption_enabled
            }
          }
        }
      }
    }
  }

  dynamic "service_connect_defaults" {
    for_each = var.service_connect_defaults != null ? [var.service_connect_defaults] : []
    content {
      namespace = service_connect_defaults.value.namespace
    }
  }
}


# ECSキャパシティプロバイダ
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy != null ? [var.default_capacity_provider_strategy] : []
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      base = default_capacity_provider_strategy.value.base
      weight = default_capacity_provider_strategy.value.weight
    }
  }
}
