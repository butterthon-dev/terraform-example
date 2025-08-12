variable "NEW_RELIC_ACCOUNT_ID" {
  type = string # Terraform CloudのVariablesに設定する
}

variable "NEW_RELIC_API_KEY" {
  type = string # Terraform CloudのVariablesに設定する
}

variable "AWS_ACCOUNT_ID" {
  type = string # Terraform CloudのVariablesに設定する
}

variable "NEW_RELIC_ACCOUNT_NAME" {
  type = string # Terraform CloudのVariablesに設定する
}

variable "NEW_RELIC_CLOUDWATCH_ENDPOINT" {
  type    = string
  default = "https://aws-api.eu01.nr-data.net/cloudwatch-metrics/v1"
}
