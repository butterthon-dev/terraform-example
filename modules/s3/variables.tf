variable "bucket_name" {
  type = string
  description = "S3バケット名"
}

variable "public_access_block" {
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  description = "S3バケットのパブリックアクセスブロック設定"
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "lifecycle_rule" {
  description = "S3バケットprivate-imagesのライフサイクルルール"
  type        = list(object(
    {
      id       = optional(string, null)
      enabled  = optional(bool, true)
      status   = optional(string, "Enabled")
      expiration = optional(object({
        date                         = optional(string, null)
        days                         = optional(number, null)
        expired_object_delete_marker = optional(bool, null)
      }), {})
      noncurrent_version_expiration = optional(object({
        newer_noncurrent_versions = optional(number, null)
        noncurrent_days           = optional(number, null)
      }), {})
      abort_incomplete_multipart_upload = optional(object({
        days_after_initiation = optional(number, null)
      }), {})
      filter = optional(object({
        prefix = optional(string, "")
        tags   = optional(map(string), {})
      }), {})
      transitions = optional(list(object({
        days = optional(number, null)
        storage_class = optional(string, null)
      })), [])
    }
  ))
  default = []
}

variable "versioning_configuration_status" {
  type = string
  description = "S3バケットのバージョニングを有効にするかどうか。デフォルト値は無効(Disabled)"
  default = "Disabled"
}

variable "expected_bucket_owner" {
  type = string
  description = "S3バケットの所有者。"
  default = null
}
