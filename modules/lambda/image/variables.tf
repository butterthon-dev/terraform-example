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

variable "environment_variables" {
  type        = map(string)
  description = "Lambda関数の環境変数"
  default     = {}
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

variable "log_group_class" {
  type        = string
  description = "ロググループのログクラス。指定可能な値はSTANDARD, INFREQUENT_ACCESS, DELIVERY。"
  default     = "STANDARD"
}

variable "retention_in_days" {
  type        = number
  description = "CloudWatchログの保持期間（日）。指定可能な値は0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653。0を選択した場合、ロググループ内のイベントは常に保持され期限切れにならない。log_group_classがDELIVERYに設定されている場合、この引数は無視され、retention_in_daysは強制的に2に設定される。"
  default     = 30
}
