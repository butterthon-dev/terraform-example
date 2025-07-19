variable "service_name" {
  description = "サービス名（例: 'operation', 'cart', 'wms'）"
  type        = string
}

variable "env" {
  description = "環境（例: 'dev', 'prod'）"
  type        = string
}

variable "name" {
  type        = string
  description = "SQSキュー名"
}

variable "sqs_managed_sse_enabled" {
  type        = bool
  description = "SQSキューがSQS管理の暗号化を使用するかどうか"
  default     = true
}

variable "kms_data_key_reuse_period_seconds" {
  type        = number
  description = "AWS KMSを再度呼び出す前に、SQSがメッセージの暗号化または復号化のためにデータキーを再利用できる時間の長さ(秒)。60秒（1分）から86,400秒（24時間）までの整数。 デフォルトは300秒（5分）"
  default     = 300
}

variable "redrive_policy" {
  type = object({
    deadLetterTargetArn = string
    maxReceiveCount     = number
  })
  description = "デッドレターキューのARNと最大受信回数を指定する"
  default     = null
}

variable "max_message_size" {
  type        = number
  description = "Amazon SQSが拒否する前にメッセージに含めることができるバイト数の制限。1024バイト(1KiB)〜262144バイト(256KiB)までの整数。デフォルトは262144バイト(256 KiB)"
  default     = 262144
}

variable "message_retention_seconds" {
  type        = number
  description = "Amazon SQSがメッセージを保持する秒数。60（1分）〜1209600（14日）までの秒数を表す整数。デフォルトは345600（4日）"
  default     = 345600
}

variable "receive_wait_time_seconds" {
  type        = number
  description = "ReceiveMessageコールがメッセージの到着を待って(ロングポーリング)戻るまでの時間。0から20（秒）までの整数。デフォルトは0で、呼び出しが即座に返されることを意味する。"
  default     = 0
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "キューの可視性タイムアウト。0から43200(12時間)までの整数。デフォルトは30"
  default     = 30
}
