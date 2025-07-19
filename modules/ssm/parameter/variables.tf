variable "name" {
  type        = string
  description = "SSMパラメータ名"
}

variable "description" {
  type        = string
  description = "SSMパラメータの説明"
  default     = ""
}

variable "type" {
  type        = string
  description = "SSMパラメータの型。有効な型は`String`, `StringList`, `SecureString`。"
  default     = "SecureString"
}

variable "value" {
  type        = string
  description = "SSMパラメータの値"
}

variable "tags" {
  type        = map(string)
  description = "SSMパラメータのタグ"
  default     = {}
}

variable "ignore_changes" {
  type        = list(string)
  description = "変更を無視する属性"
  default     = ["value"]
}
