variable "service_name" {
  type        = string
  description = "The name of the service"
}


variable "name" {
  type        = string
  description = "The name of the user pool"
}

variable "user_pool_schema" {
  description = "Schema attributes for the Cognito User Pool"
  type = list(object({
    name                     = string
    attribute_data_type      = string
    developer_only_attribute = bool
    mutable                  = bool
    required                 = bool
    string_attribute_constraints = object({
      min_length = string
      max_length = string
    })
  }))
}

variable "user_pool_tier" {
  type        = string
  description = "ユーザプール機能のプラン。有効な値はLITE, ESSENTIALS, PLUS。デフォルト値はESSENTIALS"
  default     = "ESSENTIALS"
}

variable "alias_attributes" {
  type        = list(string)
  description = "このユーザプールのエイリアスとしてサポートされる属性。有効な値はphone_number, email, またはpreferred_username。"
  default     = []
}

variable "auto_verified_attributes" {
  type        = list(string)
  description = "自動検証対象の属性。有効な値はemail, phone_number。"
  default     = []
}

variable "email_configuration" {
  type = list(object({
    configuration_set      = optional(string)
    email_sending_account  = optional(string)
    from_email_address     = optional(string)
    reply_to_email_address = optional(string)
    source_arn             = optional(string)
  }))
  default = []
}

variable "deletion_protection" {
  type        = string
  description = "削除保護が有効になっている場合、ユーザプールが誤って削除されるのを防ぐことができる。削除保護が有効になっているユーザープールを削除するには、まずこの設定値をINACTIVEにする必要があります。有効な値はACTIVE/INACTIVEで、デフォルト値はACTIVE。"
  default     = "ACTIVE"
}

variable "admin_create_user_config" {
  type = object({
    allow_admin_create_user_only = optional(bool)
    email_message                = optional(string)
    email_subject                = optional(string)
    sms_message                  = optional(string)
  })
  description = "管理者がユーザプロファイルを作成するための設定"
  default     = {}
}

variable "admin_create_user_config_allow_admin_create_user_only" {
  type        = bool
  description = "管理者のみがユーザプロファイルを作成できるようにする場合はTrue。ユーザがアプリ経由で自身で登録できるようにする場合はFalse。"
  default     = false
}

variable "admin_create_user_config_email_message" {
  type        = string
  description = "メールメッセージ用のメッセージテンプレート。{username} と {####} のプレースホルダーを含める必要がある。それぞれユーザ名と一時的なパスワードを表す。"
  default     = null
}

variable "admin_create_user_config_email_subject" {
  type        = string
  description = "メールの件名"
  default     = null
}

variable "admin_create_user_config_sms_message" {
  type        = string
  description = "SMSメッセージ用のメッセージテンプレート。{username}と{####}のプレースホルダーを含める必要がある。それぞれユーザ名と一時的なパスワードを表す。"
  default     = null
}

variable "password_policy" {
  type = object({
    minimum_length                   = optional(number)
    require_lowercase                = optional(bool)
    require_numbers                  = optional(bool)
    require_symbols                  = optional(bool)
    require_uppercase                = optional(bool)
    temporary_password_validity_days = optional(number)
    password_history_size            = optional(number)
  })
  description = "ユーザプールパスワードポリシーに関する設定"
  default = {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
    password_history_size            = 0
  }
}

variable "lambda_config" {
  type        = any
  description = "ユーザプールに関連付けられたLambdaトリガーブロック。"
  default     = {}
}

variable "lambda_config_create_auth_challenge" {
  type        = string
  description = "認証チャレンジを生成するLambda関数のARN。"
  default     = null
}

variable "lambda_config_custom_message" {
  type        = string
  description = "Lambdaトリガーのカスタムメッセージ。"
  default     = null
}

variable "lambda_config_define_auth_challenge" {
  type        = string
  description = "認証チャレンジ定義。"
  default     = null
}

variable "lambda_config_post_authentication" {
  type        = string
  description = "Post-authenticationでトリガーされるLambda関数のARN"
  default     = null
}

variable "lambda_config_post_confirmation" {
  type        = string
  description = "Post-confirmationでトリガーされるLambda関数のARN"
  default     = null
}

variable "lambda_config_pre_authentication" {
  type        = string
  description = "Pre-authenticationでトリガーされるLambda関数のARN"
  default     = null
}
variable "lambda_config_pre_sign_up" {
  type        = string
  description = "Pre-registrationでトリガーされるLambda関数のARN"
  default     = null
}

variable "lambda_config_pre_token_generation_config" {
  type = object({
    lambda_arn     = optional(string)
    lambda_version = optional(string)
  })
  description = "アクセス トークンのカスタマイズでトリガーされるLambda関数のARN"
  default     = {}
}

variable "lambda_config_user_migration" {
  type        = string
  description = "ユーザー移行でトリガーされるLambda関数のARN"
  default     = null
}

variable "lambda_config_verify_auth_challenge_response" {
  type        = string
  description = "認証チャレンジ応答を検証でトリガーされるLambda関数のARN"
  default     = null
}

variable "lambda_config_kms_key_id" {
  type        = string
  description = "Key Management Service Customer master keysのAmazonリソース名。Amazon Cognitoは、CustomEmailSenderとCustomSMSSenderに送信されるコードと一時パスワードを暗号化するためにキーを使用する。"
  default     = null
}

variable "lambda_config_custom_email_sender" {
  type = object({
    lambda_arn     = optional(string)
    lambda_version = optional(string)
  })
  description = "カスタムメール送信者でトリガーされるLambda関数のARN"
  default     = {}

}

variable "lambda_config_custom_sms_sender" {
  type = object({
    lambda_arn     = optional(string)
    lambda_version = optional(string)
  })
  description = "カスタムSMS送信者でトリガーされるLambda関数のARN"
  default     = {}
}

variable "web_authn_configuration" {
  type = object({
    relying_party_id  = optional(string)
    user_verification = optional(string)
  })
  description = "Web認証設定"
  default     = null
}

# password_policy
# sign_in_policy
# sms_configuration
# username_configuration
# verification_message_template

# verification_message_template
variable "verification_message_template" {
  type        = map(any)
  description = "検証メッセージテンプレートの設定"
  default     = {}
}

variable "verification_message_template_default_email_option" {
  type        = string
  description = "デフォルトのEメールオプション。有効な値はCONFIRM_WITH_CODE, CONFIRM_WITH_LINK. デフォルトはCONFIRM_WITH_CODE"
  default     = "CONFIRM_WITH_CODE"
}

variable "verification_message_template_email_message" {
  type        = string
  description = "検証メッセージテンプレート。{####} のプレースホルダーを含める必要がある。email_verification_messageとコンフリクトする"
  default     = null
}

variable "verification_message_template_email_message_by_link" {
  type        = string
  description = "The email message template for sending a confirmation link to the user, it must contain the `{##Click Here##}` placeholder"
  default     = null
}

variable "verification_message_template_email_subject" {
  type        = string
  description = "The subject line for the email message template for sending a confirmation code to the user"
  default     = null
}

variable "verification_message_template_email_subject_by_link" {
  type        = string
  description = "The subject line for the email message template for sending a confirmation link to the user"
  default     = null
}

variable "verification_message_template_sms_message" {
  type        = string
  description = "SMSメッセージテンプレート。{####} のプレースホルダーを含める必要がある。sms_verification_messageとコンフリクトする"
  default     = null
}

# 検証メッセージテンプレート（Email）
variable "email_verification_message" {
  type        = string
  description = "メールで送信する検証メッセージテンプレート。verification_message_templateブロックのemail_messageとコンフリクトする。"
  default     = null
}
variable "email_verification_subject" {
  type        = string
  description = "メールで送信する検証メッセージの件名。verification_message_templateブロックのemail_subjectとコンフリクトする。"
  default     = null
}

# 検証メッセージテンプレート（SMS）
variable "sms_verification_message" {
  type        = string
  description = "SMSで送信する検証メッセージテンプレート。{####} のプレースホルダーを含める必要がある。"
  default     = null
}

variable "user_pool_add_ons" {
  type        = map(any)
  description = "Configuration block for user pool add-ons to enable user pool advanced security mode features"
  default     = {}
}

variable "user_pool_add_ons_advanced_security_mode" {
  type        = string
  description = "The mode for advanced security, must be one of `OFF`, `AUDIT` or `ENFORCED`"
  default     = null
}

variable "user_pool_add_ons_advanced_security_additional_flows" {
  type        = string
  description = "Mode of threat protection operation in custom authentication. Valid values are AUDIT or ENFORCED. Default is AUDIT"
  default     = null
}

variable "read_attributes" {
  description = "The read attributes"
  type        = list(string)
}

variable "write_attributes" {
  description = "The write attributes"
  type        = list(string)
}

variable "explicit_auth_flows" {
  type        = list(string)
  description = "使用可能な認証フロー。設定可能な値はADMIN_NO_SRP_AUTH, CUSTOM_AUTH_FLOW_ONLY, USER_PASSWORD_AUTH, ALLOW_ADMIN_USER_PASSWORD_AUTH, ALLOW_CUSTOM_AUTH, ALLOW_USER_PASSWORD_AUTH, ALLOW_USER_SRP_AUTH, ALLOW_REFRESH_TOKEN_AUTH, ALLOW_USER_AUTH。"
  default     = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

variable "prevent_user_existence_errors" {
  type        = string
  description = "ユーザーが存在しない場合のエラーを防止するかどうか。有効な値はENABLED, LEGACY。"
  default     = "ENABLED"
}

variable "generate_secret" {
  type        = bool
  description = "アプリケーションクライアントのシークレットを生成するかどうか。"
  default     = false
}

variable "cognito_domain_name" {
  type        = string
  description = "Cognitoドメイン名"
  default     = null
}

variable "cognito_custom_domain_certificate_arn" {
  type        = string
  description = "Cognitoカスタムドメインの証明書ARN（us-east-1で作成したACM証明書のARNを指定する）"
  default     = null
}

variable "zone_id" {
  type        = string
  description = "Route53ゾーンID"
  default     = null
}

variable "username_configuration_case_sensitive" {
  type        = bool
  description = "ユーザー名の大文字小文字を区別するかどうか。"
  default     = false
}

variable "managed_login_version" {
  type        = number
  description = "ログインバージョン。有効な値は1（ホストされたUI）, 2（マネージドログイン）。"
  default     = 1
}
