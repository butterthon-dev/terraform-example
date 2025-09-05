locals {
  lifecycle_rules = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)
}

resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  # パブリックアクセスブロックの設定
  block_public_acls       = var.public_access_block.block_public_acls
  block_public_policy     = var.public_access_block.block_public_policy
  ignore_public_acls      = var.public_access_block.ignore_public_acls
  restrict_public_buckets = var.public_access_block.restrict_public_buckets
}

// ライフサイクルルール
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count = length(local.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main.id
  dynamic "rule" {
    for_each = local.lifecycle_rules

    content {
      id     = try(rule.value.id, null)
      status = try(rule.value.enabled ? "Enabled" : "Disabled", tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)))

      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_expiration.value.noncurrent_days, null)
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try(flatten([rule.value.abort_incomplete_multipart_upload]), [])

        content {
          days_after_initiation = try(abort_incomplete_multipart_upload.value.days_after_initiation, null)
        }
      }

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])

        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []

        content {
          prefix = try(filter.value.prefix, null)

          dynamic "tag" {
            for_each = try([for k, v in filter.value.tags : { key = k, value = v }], [])

            content {
              key   = tag.value.key
              value = tag.value.value
            }
          }
        }
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  expected_bucket_owner = var.expected_bucket_owner
  versioning_configuration {
    status = var.versioning_configuration_status
  }
}
