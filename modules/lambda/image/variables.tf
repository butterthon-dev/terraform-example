variable "service_name" {
  type        = string
  description = "サービス名"
}

variable "create_lambda_execution_role" {
  type        = bool
  description = "Lambda関数の実行ロールを作成するかどうか"
  default     = true
}

variable "lambda_execution_role_arn" {
  type        = string
  description = "Lambda関数の実行ロールのARN"
  default     = null
}

variable "lambda_execution_role_tags" {
  type        = map(string)
  description = "Lambda関数の実行ロールのタグ"
  default     = {}
}

variable "lambda_execution_role_policy" {
  type = object({
    Version = string
    Statement = list(object({
      Effect   = string
      Action   = list(string)
      Resource = list(string)
    }))
  })
  description = "Lambda関数の実行ロールのポリシー"
  default     = null
}

variable "lambda_execution_role_policy_tags" {
  type        = map(string)
  description = "Lambda関数の実行ロールポリシーのタグ"
  default     = {}
}

variable "function_name" {
  type        = string
  description = "Lambda関数名"
}

variable "description" {
  type        = string
  description = "Lambda関数の説明"
  default     = ""
}

variable "publish" {
  type        = bool
  description = "Lambda関数の作成・変更を公開するかどうか。デフォルトはfalse。"
  default     = false
}

variable "memory_size" {
  type        = number
  description = "Lambda関数のメモリサイズ(MB)"
  default     = 128
}

variable "timeout" {
  type        = number
  description = "Lambda関数の実行時間（秒）。デフォルトは3で、有効な値は1～900。"
  default     = 30
}

variable "image_uri" {
  type        = string
  description = "Lambda関数のイメージURI"
}

variable "vpc_config" {
  type = object({
    subnet_ids                  = list(string)
    security_group_ids          = list(string)
    ipv6_allowed_for_dual_stack = bool
  })
  description = "Lambda関数のVPC設定"
  default     = null
}

variable "lambda_permissions" {
  type = list(
    object({
      action                 = string
      function_name          = string
      principal              = string
      function_url_auth_type = optional(string)
      principal_org_id       = optional(string)
      qualifier              = optional(string)
      source_account         = optional(string)
      source_arn             = optional(string)
      statement_id           = optional(string)
      statement_id_prefix    = optional(string)
    })
  )
  description = "Lambdaパーミッション"
  default     = []
}
