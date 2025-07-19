variable "bucket_policy" {
  type        = string
  description = "S3バケットポリシーのJSON文字列"
}

variable "oac_name" {
  type        = string
  description = "CloudFrontオリジンアクセスコントロールの名前"
}

variable "oac_description" {
  type        = string
  description = "CloudFrontオリジンアクセスコントロールの説明"
  default = ""
}

variable "oac_type" {
  type = string
  description = "CloudFrontオリジンアクセスコントロールのオリジンタイプ"
  default     = "s3"
}

variable "oac_signing_behavior" {
  type        = string
  description = "CloudFrontオリジンアクセスコントロールの署名動作"
  default     = "always"
}

variable "oac_signing_protocol" {
  type        = string
  description = "CloudFrontオリジンアクセスコントロールの署名プロトコル"
  default     = "sigv4"
}

variable "bucket_regional_domain_name" {
  type        = string
  description = "S3バケットのリージョナルドメイン名"
}

variable "origin_id" {
  type        = string
  description = "CloudFrontオリジンのID"
}

variable "bucket_id" {
  type        = string
  description = "S3バケットのID"
}
