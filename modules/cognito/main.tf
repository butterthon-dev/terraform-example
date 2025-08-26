locals {
  admin_create_user_config_default = {
    allow_admin_create_user_only = lookup(var.admin_create_user_config, "allow_admin_create_user_only", null) == null ? var.admin_create_user_config_allow_admin_create_user_only : lookup(var.admin_create_user_config, "allow_admin_create_user_only")
    email_message                = lookup(var.admin_create_user_config, "email_message", null) == null ? (var.email_verification_message == "" || var.email_verification_message == null ? var.admin_create_user_config_email_message : var.email_verification_message) : lookup(var.admin_create_user_config, "email_message")
    email_subject                = lookup(var.admin_create_user_config, "email_subject", null) == null ? (var.email_verification_subject == "" || var.email_verification_subject == null ? var.admin_create_user_config_email_subject : var.email_verification_subject) : lookup(var.admin_create_user_config, "email_subject")
    sms_message                  = lookup(var.admin_create_user_config, "sms_message", null) == null ? var.admin_create_user_config_sms_message : lookup(var.admin_create_user_config, "sms_message")
  }
  admin_create_user_config = [local.admin_create_user_config_default]

  lambda_config_default = {
    create_auth_challenge          = lookup(var.lambda_config, "create_auth_challenge", var.lambda_config_create_auth_challenge)
    custom_message                 = lookup(var.lambda_config, "custom_message", var.lambda_config_custom_message)
    define_auth_challenge          = lookup(var.lambda_config, "define_auth_challenge", var.lambda_config_define_auth_challenge)
    post_authentication            = lookup(var.lambda_config, "post_authentication", var.lambda_config_post_authentication)
    post_confirmation              = lookup(var.lambda_config, "post_confirmation", var.lambda_config_post_confirmation)
    pre_authentication             = lookup(var.lambda_config, "pre_authentication", var.lambda_config_pre_authentication)
    pre_sign_up                    = lookup(var.lambda_config, "pre_sign_up", var.lambda_config_pre_sign_up)
    pre_token_generation_config    = lookup(var.lambda_config, "pre_token_generation_config", var.lambda_config_pre_token_generation_config) == {} ? [] : [lookup(var.lambda_config, "pre_token_generation_config", var.lambda_config_pre_token_generation_config)]
    user_migration                 = lookup(var.lambda_config, "user_migration", var.lambda_config_user_migration)
    verify_auth_challenge_response = lookup(var.lambda_config, "verify_auth_challenge_response", var.lambda_config_verify_auth_challenge_response)
    kms_key_id                     = lookup(var.lambda_config, "kms_key_id", var.lambda_config_kms_key_id)
    custom_email_sender            = lookup(var.lambda_config, "custom_email_sender", var.lambda_config_custom_email_sender) == {} ? [] : [lookup(var.lambda_config, "custom_email_sender", var.lambda_config_custom_email_sender)]
    custom_sms_sender              = lookup(var.lambda_config, "custom_sms_sender", var.lambda_config_custom_sms_sender) == {} ? [] : [lookup(var.lambda_config, "custom_sms_sender", var.lambda_config_custom_sms_sender)]
  }
  lambda_config = var.lambda_config == null || length(var.lambda_config) == 0 ? [] : [local.lambda_config_default]

  verification_message_template_default = {
    default_email_option  = lookup(var.verification_message_template, "default_email_option", null) == null ? var.verification_message_template_default_email_option : lookup(var.verification_message_template, "default_email_option")
    email_message         = lookup(var.verification_message_template, "email_message", null) == null ? var.verification_message_template_email_message : lookup(var.verification_message_template, "email_message")
    email_message_by_link = lookup(var.verification_message_template, "email_message_by_link", null) == null ? var.verification_message_template_email_message_by_link : lookup(var.verification_message_template, "email_message_by_link")
    email_subject         = lookup(var.verification_message_template, "email_subject", null) == null ? var.verification_message_template_email_subject : lookup(var.verification_message_template, "email_subject")
    email_subject_by_link = lookup(var.verification_message_template, "email_subject_by_link", null) == null ? var.verification_message_template_email_subject_by_link : lookup(var.verification_message_template, "email_subject_by_link")
    sms_message           = lookup(var.verification_message_template, "sms_message", null) == null ? var.verification_message_template_sms_message : lookup(var.verification_message_template, "sms_message")
  }

  verification_message_template = [local.verification_message_template_default]

  verification_email_subject = local.verification_message_template_default.email_subject == "" || local.verification_message_template_default.email_subject == null ? (
    var.email_verification_subject == "" || var.email_verification_subject == null ? var.admin_create_user_config_email_subject : var.email_verification_subject
  ) : null
  verification_email_message = local.verification_message_template_default.email_message == "" || local.verification_message_template_default.email_message == null ? (
    var.email_verification_message == "" || var.email_verification_message == null ? var.admin_create_user_config_email_message : var.email_verification_message
  ) : null

  user_pool_add_ons_default = {
    advanced_security_mode             = lookup(var.user_pool_add_ons, "advanced_security_mode", null) == null ? var.user_pool_add_ons_advanced_security_mode : lookup(var.user_pool_add_ons, "advanced_security_mode")
    advanced_security_additional_flows = lookup(var.user_pool_add_ons, "advanced_security_additional_flows", null) == null ? var.user_pool_add_ons_advanced_security_additional_flows : lookup(var.user_pool_add_ons, "advanced_security_additional_flows")
  }

  user_pool_add_ons = var.user_pool_add_ons_advanced_security_mode == null && var.user_pool_add_ons_advanced_security_additional_flows == null && length(var.user_pool_add_ons) == 0 ? [] : [local.user_pool_add_ons_default]
}


resource "aws_cognito_user_pool" "main" {
  name = "${var.service_name}-userpool-${var.name}"

  user_pool_tier           = var.user_pool_tier
  alias_attributes         = var.alias_attributes
  auto_verified_attributes = var.auto_verified_attributes

  # 検証メッセージテンプレート
  email_verification_message = var.email_verification_message
  email_verification_subject = var.email_verification_subject
  sms_verification_message   = var.sms_verification_message

  deletion_protection = var.deletion_protection

  dynamic "schema" {
    for_each = var.user_pool_schema
    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      developer_only_attribute = schema.value.developer_only_attribute
      mutable                  = schema.value.mutable
      required                 = schema.value.required

      string_attribute_constraints {
        min_length = schema.value.string_attribute_constraints.min_length
        max_length = schema.value.string_attribute_constraints.max_length
      }
    }
  }

  dynamic "admin_create_user_config" {
    for_each = local.admin_create_user_config
    content {
      allow_admin_create_user_only = lookup(admin_create_user_config.value, "allow_admin_create_user_only", false)

      dynamic "invite_message_template" {
        for_each = lookup(admin_create_user_config.value, "email_message", null) == null && lookup(admin_create_user_config.value, "email_subject", null) == null && lookup(admin_create_user_config.value, "sms_message", null) == null ? [] : [1]
        content {
          email_message = lookup(admin_create_user_config.value, "email_message", null)
          email_subject = lookup(admin_create_user_config.value, "email_subject", null)
          sms_message   = lookup(admin_create_user_config.value, "sms_message", null)
        }
      }
    }
  }

  dynamic "email_configuration" {
    for_each = var.email_configuration
    content {
      email_sending_account = email_configuration.value.email_sending_account
    }
  }

  dynamic "password_policy" {
    for_each = var.password_policy != null ? [var.password_policy] : []
    content {
      minimum_length                   = password_policy.value.minimum_length
      require_lowercase                = password_policy.value.require_lowercase
      require_numbers                  = password_policy.value.require_numbers
      require_symbols                  = password_policy.value.require_symbols
      require_uppercase                = password_policy.value.require_uppercase
      temporary_password_validity_days = password_policy.value.temporary_password_validity_days
      password_history_size            = password_policy.value.password_history_size
    }
  }

  dynamic "lambda_config" {
    for_each = local.lambda_config
    content {
      create_auth_challenge = lookup(lambda_config.value, "create_auth_challenge")
      custom_message        = lookup(lambda_config.value, "custom_message")
      define_auth_challenge = lookup(lambda_config.value, "define_auth_challenge")
      post_authentication   = lookup(lambda_config.value, "post_authentication")
      post_confirmation     = lookup(lambda_config.value, "post_confirmation")
      pre_authentication    = lookup(lambda_config.value, "pre_authentication")
      pre_sign_up           = lookup(lambda_config.value, "pre_sign_up")
      pre_token_generation  = lookup(lambda_config.value, "pre_token_generation")
      dynamic "pre_token_generation_config" {
        for_each = lookup(lambda_config.value, "pre_token_generation_config")
        content {
          lambda_arn     = lookup(pre_token_generation_config.value, "lambda_arn")
          lambda_version = lookup(pre_token_generation_config.value, "lambda_version")
        }
      }
      user_migration                 = lookup(lambda_config.value, "user_migration")
      verify_auth_challenge_response = lookup(lambda_config.value, "verify_auth_challenge_response")
      kms_key_id                     = lookup(lambda_config.value, "kms_key_id")
      dynamic "custom_email_sender" {
        for_each = lookup(lambda_config.value, "custom_email_sender")
        content {
          lambda_arn     = lookup(custom_email_sender.value, "lambda_arn")
          lambda_version = lookup(custom_email_sender.value, "lambda_version")
        }
      }
      dynamic "custom_sms_sender" {
        for_each = lookup(lambda_config.value, "custom_sms_sender")
        content {
          lambda_arn     = lookup(custom_sms_sender.value, "lambda_arn")
          lambda_version = lookup(custom_sms_sender.value, "lambda_version")
        }
      }
    }
  }

  dynamic "verification_message_template" {
    for_each = local.verification_message_template
    content {
      default_email_option  = lookup(verification_message_template.value, "default_email_option", "CONFIRM_WITH_CODE")
      email_message         = lookup(verification_message_template.value, "email_message", null)
      email_message_by_link = lookup(verification_message_template.value, "email_message_by_link", null)
      email_subject         = lookup(verification_message_template.value, "email_subject", null)
      email_subject_by_link = lookup(verification_message_template.value, "email_subject_by_link", null)
      sms_message           = lookup(verification_message_template.value, "sms_message", null)
    }
  }

  dynamic "user_pool_add_ons" {
    for_each = local.user_pool_add_ons
    content {
      advanced_security_mode = lookup(user_pool_add_ons.value, "advanced_security_mode")

      dynamic "advanced_security_additional_flows" {
        for_each = lookup(user_pool_add_ons.value, "advanced_security_additional_flows") != null ? [1] : []
        content {
          custom_auth_mode = lookup(user_pool_add_ons.value, "advanced_security_additional_flows")
        }
      }
    }
  }

  username_configuration {
    case_sensitive = var.username_configuration_case_sensitive
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name = "${var.service_name}-appclient-${var.name}"

  user_pool_id = aws_cognito_user_pool.main.id

  # Cart/Operation側の設定
  #   access_token_validity  = 60
  #   id_token_validity      = 5
  #   refresh_token_validity = 30

  # Rmc Store Localの設定
  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 5

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  read_attributes               = var.read_attributes
  write_attributes              = var.write_attributes
  explicit_auth_flows           = var.explicit_auth_flows
  prevent_user_existence_errors = var.prevent_user_existence_errors
  generate_secret               = var.generate_secret
}

resource "aws_cognito_user_pool_domain" "main" {
  count = var.cognito_domain_name != null ? 1 : 0

  domain       = var.cognito_domain_name
  user_pool_id = aws_cognito_user_pool.main.id
  certificate_arn = var.cognito_custom_domain_certificate_arn
  managed_login_version = var.managed_login_version
}

resource "aws_route53_record" "main" {
  count = var.cognito_custom_domain_certificate_arn != null ? 1 : 0

  name    = aws_cognito_user_pool_domain.main[0].domain
  type    = "A"
  zone_id = var.zone_id
  alias {
    evaluate_target_health = false

    name    = aws_cognito_user_pool_domain.main[0].cloudfront_distribution
    zone_id = aws_cognito_user_pool_domain.main[0].cloudfront_distribution_zone_id
  }
}
