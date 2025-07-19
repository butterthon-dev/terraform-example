locals {
  common_name = "${var.env}-${var.service_name}"
}

resource "aws_sqs_queue" "main" {
  name                              = "${local.common_name}-sqs-${var.name}"
  fifo_queue                        = false
  sqs_managed_sse_enabled           = var.sqs_managed_sse_enabled
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  max_message_size                  = var.max_message_size
  message_retention_seconds         = var.message_retention_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  redrive_policy                    = var.redrive_policy != null ? jsonencode(var.redrive_policy) : null
}
