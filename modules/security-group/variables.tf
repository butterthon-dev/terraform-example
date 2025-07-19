variable "name" {
  type        = string
  description = "セキュリティグループ名"
}

variable "description" {
  type        = string
  description = "セキュリティグループの説明"
  default = ""
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "Ingress CIDR blocks"
}

variable "ingress_rules" {
  type        = list(string)
  description = "Ingress rules"
  default = []
}

variable "ingress_with_cidr_blocks" {
  type        = list(any)
  description = "Ingress with CIDR blocks"
  default = []
}

variable "egress_rules" {
  type        = list(string)
  description = "Egress rules"
  default = []
}

variable "egress_with_cidr_blocks" {
  type        = list(any)
  description = "Egress with CIDR blocks"
  default = []
}
