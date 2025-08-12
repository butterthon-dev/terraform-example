variable "service_name" {
  type = string
}

variable "env" {
  type = string
}

variable "new_relic_account_id" {
  type = string
}

variable "new_relic_api_key" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "new_relic_account_name" {
  type = string
}

variable "newrelic_account_region" {
  type    = string
  default = "US"

  validation {
    condition     = contains(["US", "EU"], var.newrelic_account_region)
    error_message = "newrelic_account_regionに指定できる有効な値は'US'または'EU'です。"
  }
}

variable "metrics_include_filters" {
  type = list(object({
    namespace = string
    metric_names = list(string)
  }))
  description = "このパラメーターを指定するとストリームはここで指定したnamespaceからmetric_namesのみを送信する。metric_namesを指定しないまたは空(`[]`)の場合はすべてのメトリック ネームスペースが含まれる。"
  default = []
}

variable "metrics_exclude_filters" {
  type = list(object({
    namespace = string
    metric_names = list(string)
  }))
  description = "このパラメーターを指定するとストリームはここで指定したnamespaceとmetric_namesを除いたすべてのメトリック ネームスペースからメトリックを送信する。metric_namesを指定しないまたは空(`[]`)の場合、すべてのメトリック ネームスペースが除外される。"
  default = []
}
