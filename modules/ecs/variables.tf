variable "cluster_name" {
  type        = string
  description = "ECSクラスター名"
}

variable "services" {
  type        = any
  description = "ECSサービス名"
  default     = {}
}
