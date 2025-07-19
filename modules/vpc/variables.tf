variable "vpc_name" {
  type = string
  description = "VPC名"
}

variable "vpc_cidr" {
  type = string
  description = "VPCのCIDR"
}

variable "enable_nat_gateway" {
  type = bool
  description = "NATゲートウェイを有効にするかどうか"
  default = true
}

variable "single_nat_gateway" {
  type = bool
  description = "単一のNATゲートウェイを使用するかどうか"
  default = true
}

variable "one_nat_gateway_per_az" {
  type = bool
  description = "AZごとに1つのNATゲートウェイを使用するかどうか"
  default = false
}

variable "enable_vpn_gateway" {
  type = bool
  description = "VPNゲートウェイを有効にするかどうか"
  default = false
}