################################################################################
# セキュリティグループ
################################################################################
variable "sg_description" {
  type = string
  description = "セキュリティグループの説明"
  default = "ALB"
}

variable "egress_rules" {
  type = list(object({
    description = optional(string)
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string)
    security_groups = optional(list(string))
    self = optional(bool)
  }))
  description = "アウトバウンドルール"
  default = [ {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = []
    self = false
  } ]
}

variable "ingress_rules" {
  type = list(object({
    description = optional(string)
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string)
    security_groups = optional(list(string))
    self = optional(bool)
  }))
  description = "インバウンドルール"
}

################################################################################
# ALB
################################################################################
variable "service_name" {
  type = string
  description = "サービス名"
}

variable "name" {
  type = string
  description = "ロードバランサの名前"
}

variable "internal" {
  type = bool
  description = "内部ロードバランサかどうか"
  default = false
}

variable "load_balancer_type" {
  type = string
  description = "ロードバランサのタイプ"
  default = "application"
}

variable "subnet_ids" {
  type = list(string)
  description = "ロードバランサが配置されるサブネットのID"
}

variable "enable_deletion_protection" {
  type = bool
  description = "ロードバランサの削除保護"
  default = true
}

variable "access_logs" {
  type = object({
    bucket = string
    prefix = string
    enabled = bool
  })
  description = "アクセスログの設定"
  default = null
}

variable "tags" {
  type = map(string)
  description = "ロードバランサのタグ"
  default = {}
}


################################################################################
# ターゲットグループ
################################################################################
variable "ip_address_type" {
  type = string
  description = "IPアドレスのタイプ"
  default = "ipv4"
}

variable "load_balancing_algorithm_type" {
  type = string
  description = "ロードバランシングアルゴリズムのタイプ"
  default = "round_robin"
}

variable "target_group_port" {
  type = number
  description = "ポート番号"
}

variable "target_group_protocol" {
  type = string
  description = "プロトコル"
  default = "HTTP"
}

variable "protocol_version" {
  type = string
  description = "プロトコルバージョン"
  default = "HTTP1"
}

variable "target_type" {
  type = string
  description = "ターゲットのタイプ"
  default = "ip"
}

variable "vpc_id" {
  type = string
  description = "VPCのID"
}

variable "health_check" {
  type = object({
    enabled = bool
    path = string
    port = string
    protocol = string
    matcher = optional(string)
    interval = optional(number)
    timeout = optional(number)
    healthy_threshold = optional(number)
    unhealthy_threshold = optional(number)
  })
  description = "ヘルスチェックの設定"
  default = null
}


################################################################################
# リスナー
################################################################################
variable "listener_port" {
  type = number
  description = "ALBリスナーのポート"
}

variable "listener_protocol" {
  type = string
  description = "リスナーのプロトコル"
}

variable "ssl_policy" {
  type = string
  description = "SSLポリシー"
  default = null
}

variable "certificate_arn" {
  type = string
  description = "証明書のARN"
  default = null
}

################################################################################
# Route53
################################################################################
variable "zone_id" {
  type        = string
  description = "Route53のゾーンID"
  default     = null
}

variable "domain_name" {
  type        = string
  description = "ドメイン名"
  default     = null
}
