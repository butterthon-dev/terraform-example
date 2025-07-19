resource "aws_secretsmanager_secret" "main" {
  name                           = var.name
  description                    = var.description
  kms_key_id                     = var.kms_key_id
  name_prefix                    = var.name_prefix
  recovery_window_in_days        = var.recovery_window_in_days
  force_overwrite_replica_secret = var.force_overwrite_replica_secret
  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  dynamic "replica" {
    for_each = var.replica

    content {
      kms_key_id = try(replica.value.kms_key_id, null)
      region     = try(replica.value.region, replica.key)
    }
  }
}

resource "aws_secretsmanager_secret_rotation" "main" {
  count = var.enabled_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.main.id
  rotation_lambda_arn = var.rotation_lambda_arn

  dynamic "rotation_rules" {
    for_each = var.rotation_rules != null ? [var.rotation_rules] : []

    content {
      automatically_after_days = rotation_rules.value.automatically_after_days
      duration                 = rotation_rules.value.duration
      schedule_expression      = rotation_rules.value.schedule_expression
    }
  }
}
