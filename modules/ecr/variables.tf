variable "repository_name" {
  description = "リポジトリ名"
  type        = string
}

variable "image_tag_mutability" {
  description = "イメージタグの変更可能性"
  type        = string
  default     = "MUTABLE"
}

variable "enable_image_scanning" {
  description = "イメージスキャンの有効化"
  type        = bool
  default     = false
}
