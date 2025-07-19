variable "service_name" {
  description = "サービス名（例: 'operation', 'cart', 'wms'）"
  type        = string
}

variable "env" {
  description = "環境（例: 'dev', 'prod'）"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "Elasticache Cluster VPC ID"
}

variable "egress_rules" {
  type = list(object({
    description        = optional(string)
    security_group_ids = optional(list(string))
    from_port          = number
    to_port            = number
    protocol           = string
    cidr_blocks        = optional(list(string))
    security_groups    = optional(list(string))
  }))
  description = "アウトバウンドルール"
  default = [{
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
  }]
}

variable "ingress_rules" {
  type = list(object({
    description        = optional(string)
    security_group_ids = optional(list(string))
    from_port          = number
    to_port            = number
    protocol           = string
    cidr_blocks        = optional(list(string))
    security_groups    = optional(list(string))
  }))
  description = "インバウンドルール"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Elasticache Cluster Subnet IDs"
}

variable "replication_group_id" {
  type        = string
  description = "Replication Group ID"
}

variable "description" {
  type        = string
  description = "Replication Group Description"
  default     = "Elasticache Cluster"
}

variable "cluster_mode" {
  type        = string
  description = "クラスタ・モードが有効か無効かを指定。有効な値はenabled, disabled, compatible。"
  default     = "disabled"
}

variable "node_type" {
  type        = string
  description = "Elasticache Cluster Node Type"
  default     = "cache.t2.micro"
}

variable "engine_version" {
  type        = string
  description = "使用するキャッシュ・エンジンのバージョン番号。設定されていない場合は最新バージョンになります。"
  default     = "7.2"
}

variable "parameter_group_name" {
  type        = string
  description = "Elasticache Cluster Parameter Group Name"
  default     = "default.valkey7"
}

variable "port" {
  type        = number
  description = "各キャッシュ・ノードが接続を受け付けるポート番号"
  default     = 6379
}

variable "apply_immediately" {
  type        = bool
  description = "データベースの変更を即時適用するか、または次のメンテナンスウィンドウ中に適用するかを指定"
  default     = false
}

variable "transit_encryption_enabled" {
  type        = bool
  description = "転送中の暗号化を有効にする"
  default     = false
}

variable "automatic_failover_enabled" {
  type        = bool
  description = "自動フェイルオーバーを有効にする"
  default     = false
}

variable "num_node_groups" {
  type        = number
  description = "Redisレプリケーション・グループのノード・グループ（シャード）の数"
  default     = 1
}

variable "replicas_per_node_group" {
  type        = number
  description = "各ノードグループのレプリカノード数。有効な値は0から5。"
  default     = 0
}

variable "slow_log_format" {
  type        = string
  description = "Redis SLOWLOGのログフォーマット"
  default     = "json"
}

variable "engine_log_format" {
  type        = string
  description = "Redis Engine Logのログフォーマット"
  default     = "json"
}

variable "log_delivery_configurations" {
  type = list(object({
    destination      = string
    destination_type = string
    log_format       = string
    log_type         = string
  }))
  description = "Redis SLOWLOGまたはRedis Engine LogをCloudWatch LogsまたはKinesis Data Firehoseにストリーミングする設定"
  default     = []
}
