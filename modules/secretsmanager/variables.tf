variable "name" {
  type        = string
  description = "シークレットの名前"
}

variable "description" {
  type        = string
  description = "シークレットの説明"
  default     = ""
}

variable "kms_key_id" {
  type        = string
  description = "シークレットの暗号化に使用するKMSキーのID"
  default     = null
}

variable "name_prefix" {
  type        = string
  description = "シークレットの名前のプレフィックス"
  default     = null
}

variable "recovery_window_in_days" {
  type        = number
  description = "AWS Secrets Managerがシークレットを削除するまでの待機日数。7～30日の範囲を指定可能。リカバリせずに強制的に削除する場合は0。デフォルト値は30。"
  default     = null
}

variable "replica" {
  type = map(object({
    region     = string
    kms_key_id = string
  }))
  description = "シークレットのレプリカ"
  default     = {}
}

variable "force_overwrite_replica_secret" {
  type        = bool
  description = "Destination Regionにある同名のシークレットを上書きするかどうか"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "SecretsManagerのタグ"
  default     = {}
}

variable "enabled_rotation" {
  type        = bool
  description = "シークレットのローテーションを有効にするかどうか"
  default     = false
}

variable "rotation_lambda_arn" {
  type        = string
  description = "シークレットのローテーションで実行するLambda関数のARN"
  default     = null
}

variable "rotation_rules" {
  type = object({
    automatically_after_days = optional(number)
    duration                 = optional(string)
    schedule_expression      = optional(string)
  })
  description = "シークレットのローテーションルール"
  default     = null
}
