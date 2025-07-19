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
      filter = optional(object({
        prefix = optional(string, "")
        tags   = optional(map(string), {})
      }), {})
    }
  ))
  default = []
}
