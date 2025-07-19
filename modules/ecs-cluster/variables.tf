variable "name" {
  type        = string
  description = "ECSクラスター名"
}

variable "settings" {
  type = list(object({
    name = string
    value = string
  }))
  description = "ECSクラスターの設定"
  default     = []
}

variable "configuration" {
  type = object({
    execute_command_configuration = object({
      logging = string
      log_configuration = object({
        cloud_watch_encryption_enabled = bool
        cloud_watch_log_group_name     = string
      })
    })
  })
  description = "ECSクラスターの実行コマンド設定"
  default     = null
}

variable "service_connect_defaults" {
  type = object({
    namespace = string
  })
  description = "ECSクラスターのサービス接続デフォルト設定"
  default     = null
}

variable "default_capacity_provider_strategy" {
  type = object({
    capacity_provider = string
    base = number
    weight = number
  })
  description = "ECSクラスターのデフォルトキャパシティプロバイダー戦略"
  default     = {
    base = 1
    weight = 100
    capacity_provider = "FARGATE"
  }
}
