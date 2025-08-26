locals {
  domain       = "viz.butterthon-dev.jp"
  service_name = "viz-butterthon-dev"
}

########################################################
# ECS + SQS検証用のTerraformコード
########################################################

# VPC, PublicNetwork, PrivateNetwork
module "network" {
  source   = "../../modules/vpc"
  vpc_name = "vpc-${local.service_name}"
  vpc_cidr = "10.0.0.0/16"

  # Single NAT Gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}

# ECS名前空間
resource "aws_service_discovery_http_namespace" "main" {
  name        = "butterthon_dev"
  description = ""
}

# ECR
module "ecr" {
  source = "../../modules/ecr"

  service_name = local.service_name
  for_each = { for i in [
    { "name" = "producer" },
    # { "name" = "consumer" },
    # { "name" = "poller" },
    { "name" = "wms_refresh_token" },
  ] : i.name => i }
  repository_name = each.value.name
}

# # SQS（スタンダード）
# module "sqs" {
#   source     = "../../modules/sqs/standard"
#   env          = "dev"
#   service_name = local.service_name
#   name       = "deliveries"
# }

# # SecretsManager
# module "secret_token" {
#   source = "../../modules/secretsmanager"

#   name        = "env/wms/logiless"
# }

# ALB - プロデューササービス
module "alb_producer" {
  source = "../../modules/alb"

  service_name = local.service_name
  name         = "producer"
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.public_subnets
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  ingress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  listener_port     = 443
  listener_protocol = "HTTPS"

  target_group_port     = 8000
  target_group_protocol = "HTTP"

  health_check = {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = 200
    path                = "/healthz"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = aws_acm_certificate.main.arn
  zone_id         = data.aws_route53_zone.root.zone_id
  domain_name     = data.aws_route53_zone.root.name

  enable_deletion_protection = false
}

# Service Discovery 名前空間
resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = "butterthon-dev.internal"
  description = "Service discovery for internal API"
  vpc         = module.network.vpc_id
}

# ECSクラスタ
module "ecs_cluster" {
  source = "../../modules/ecs-cluster"
  name   = "ecs-${local.service_name}"

  # settings = [
  #   {
  #     name  = "containerInsights"
  #     value = "enabled"
  #   }
  # ]

  configuration = {
    execute_command_configuration = {
      # logging = "NONE"
      logging = "DEFAULT"
      # log_configuration = {
      #   cloud_watch_encryption_enabled = true
      #   cloud_watch_log_group_name     = "ecs-${local.service_name}"
      # }
    }
  }

  service_connect_defaults = {
    namespace = aws_service_discovery_http_namespace.main.arn
  }

  default_capacity_provider_strategy = {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

# ECSサービス
module "ecs_service_producer" {
  source = "../../modules/ecs-service/fargate"

  service_name = local.service_name

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  ingress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # タスクロール
  create_task_role = true
  task_role_policy = {
    Version = "2012-10-17"
    Statement = [
      # SSMセッションマネージャ
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = ["arn:aws:ssmmessages:ap-northeast-1:184321346292:*"]
      },
    ]
  }

  # ECSタスク定義
  task_cpu    = 256
  task_memory = 512
  container_definitions = [
    {
      name                   = "api"
      image                  = "184321346292.dkr.ecr.ap-northeast-1.amazonaws.com/viz-butterthon-dev-ecr-producer:latest"
      essential              = true
      readonlyRootFilesystem = false
      portMappings = [
        {
          name          = "api"
          containerPort = 8000
          protocol      = "tcp"
        }
      ]
    }
  ]

  # ECSサービス
  vpc_id                         = module.network.vpc_id
  ecs_cluster_id                 = module.ecs_cluster.cluster_id
  ecs_cluster_name               = module.ecs_cluster.cluster_name
  ecs_service_name               = "producer"
  desired_count                  = 1
  enabled_service_discovery      = true
  service_discovery_name         = "producer"
  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.internal.id
  enable_execute_command         = true
  network_configuration = {
    subnet_ids       = module.network.private_subnets
    assign_public_ip = false
  }

  load_balancer = {
    container_name   = "api"
    container_port   = 8000
    target_group_arn = module.alb_producer.target_group_arn
  }
}

# module "ecs_service_poller" {
#   source = "../../modules/ecs-service"

#   # セキュリティグループ
#   vpc_id        = module.network.vpc_id
#   ingress_rules = []

#   # ECSタスク定義
#   family_name = "poller-${local.service_name}"
#   task_cpu    = 256
#   task_memory = 512
#   container_definitions = [
#     {
#       name  = "api"
#       image = "184321346292.dkr.ecr.ap-northeast-1.amazonaws.com/poller-viz-butterthon-dev:latest"
#       environment = [
#         { name = "SQS_QUEUE_URL", value = module.sqs.queue_url },
#         { name = "CALLBACK_URL", value = "http://consumer.butterthon-dev.internal:8000/call-back" }
#       ]
#       essential              = true
#       readonlyRootFilesystem = false
#     }
#   ]

#   # ECSサービス
#   service_name     = "poller-${local.service_name}"
#   cluster_id       = module.ecs_cluster.cluster_id
#   desired_count    = 1
#   platform_version = "LATEST"
#   # service_connect_configuration = {
#   #   enabled = true
#   #   service = {
#   #     client_alias = {
#   #       dns_name = "producer-internal"
#   #       port     = 8000
#   #     }
#   #     port_name      = "api"
#   #     discovery_name = "producer-internal"
#   #   }
#   # }

#   enabled_service_discovery      = true
#   service_discovery_name         = "poller"
#   service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.internal.id

#   network_configuration = {
#     subnet_ids       = module.network.private_subnets
#     assign_public_ip = false
#   }
# }

# module "ecs_service_consumer" {
#   source = "../../modules/ecs-service"

#   # セキュリティグループ
#   vpc_id = module.network.vpc_id
#   ingress_rules = [
#     {
#       from_port   = 8000
#       to_port     = 8000
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   ]

#   # ECSタスク定義
#   family_name = "consumer-${local.service_name}"
#   task_cpu    = 256
#   task_memory = 512
#   container_definitions = [
#     {
#       name  = "api"
#       image = "184321346292.dkr.ecr.ap-northeast-1.amazonaws.com/consumer-viz-butterthon-dev:latest"
#       environment = [
#         { name = "PORT", value = 8000 },
#       ]
#       essential              = true
#       readonlyRootFilesystem = false
#     }
#   ]

#   # ECSサービス
#   service_name     = "consumer-${local.service_name}"
#   cluster_id       = module.ecs_cluster.cluster_id
#   desired_count    = 1
#   platform_version = "LATEST"
#   # service_connect_configuration = {
#   #   enabled = true
#   #   service = {
#   #     client_alias = {
#   #       dns_name = "producer-internal"
#   #       port     = 8000
#   #     }
#   #     port_name      = "api"
#   #     discovery_name = "producer-internal"
#   #   }
#   # }

#   enabled_service_discovery      = true
#   service_discovery_name         = "consumer"
#   service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.internal.id

#   network_configuration = {
#     subnet_ids       = module.network.private_subnets
#     assign_public_ip = false
#   }
# }

# module "elasticache" {
#   source = "../../modules/elasticache/valkey"

#   env          = "dev"
#   service_name = local.service_name

#   replication_group_id       = "smpl"
#   parameter_group_name       = "default.valkey7"
#   # engine                     = "valkey"
#   # engine_version             = "7.2"
#   node_type                  = "cache.t2.micro"
#   cluster_mode               = "disabled"
#   num_node_groups            = 1
#   replicas_per_node_group    = 0
#   automatic_failover_enabled = false
#   vpc_id                     = module.network.vpc_id
#   subnet_ids                 = module.network.private_subnets
#   ingress_rules = [
#     {
#       from_port = 6379
#       to_port   = 6379
#       protocol  = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#       # security_groups = [module.ecs_service_producer.attached_security_group_id]
#     }
#   ]
# }



########################################################
# Lambda検証用のTerraformコード
########################################################

# # S3 + CloudFrontの検証
# module "private_images" {
#   source      = "../../modules/s3"
#   bucket_name = "private-images-example"
#   lifecycle_rule = [
#     {
#       id = "tmp-folder-expiration"
#       enabled = true
#       expiration = {
#         days = 1
#         expired_object_delete_marker = false
#       }
#       filter = {
#         prefix = "tmp/"
#       }
#     }
#   ]
# }

# module "cloudfront_private_images" {
#     source = "../../modules/cloud-front"
#     oac_name = "OAC-DEV-private-images-example"
#     bucket_regional_domain_name = module.private_images.bucket_regional_domain_name
#     origin_id = module.private_images.bucket_name
#     bucket_id = module.private_images.bucket_id
#     bucket_policy = data.aws_iam_policy_document.private_images_policy.json
# }

# module "lambda_hello_world" {
#   source = "../../modules/lambda"
#   function_name = "func-hello-world"
#   package_type = "Image"
#   role_arn = aws_iam_role.lambda_role.arn
#   image_uri = "184321346292.dkr.ecr.ap-northeast-1.amazonaws.com/images:latest"
# }


# # ########################################################
# # # Lambda(Docker) × SecretsManagerのローテーション検証
# # ########################################################
# module "lambda_hello_world_from_image" {
#   source = "../../modules/lambda/image"
#   service_name = local.service_name
#   function_name = "wms_refresh_token"
#   image_uri = "${module.ecr["wms_refresh_token"].repository_url}:latest"
#   publish = true

#   create_lambda_execution_role = true
#   lambda_execution_role_policy = {
#     Version = "2012-10-17"
#     Statement = [
#       # 特定のSecretsManagerの編集を許可するポリシー
#       {
#         Effect   = "Allow"
#         Action   = ["secretsmanager:*"]
#         Resource = [
#           module.secret_token.secret_arn,
#         ]
#       },
#     ]
#   }

#   lambda_permissions = [
#     {
#       action = "lambda:InvokeFunction"
#       function_name = module.lambda_hello_world_from_image.lambda_function_name
#       principal = "secretsmanager.amazonaws.com"
#       source_arn = module.secret_token.secret_arn
#     }
#   ]
# }


# ########################################################
# # Lambda(Zip) × SecretsManagerのローテーション検証
# ########################################################

# module "wms_refresh_token" {
#   source = "../../modules/lambda/zip"
#   service_name = local.service_name

#   # create_lambda_execution_role = true
#   # lambda_execution_role_policy = {
#   #   Version = "2012-10-17"
#   #   Statement = [
#   #     # 特定のSecretsManagerの編集を許可するポリシー
#   #     {
#   #       Effect   = "Allow"
#   #       Action   = ["secretsmanager:*"]
#   #       Resource = [
#   #         module.secret_token.secret_arn,
#   #       ]
#   #     },
#   #   ]
#   # }

#   # lambda_permissions = [
#   #   {
#   #     action = "lambda:InvokeFunction"
#   #     function_name = module.lambda_hello_world_from_zip.lambda_function_name
#   #     principal = "secretsmanager.amazonaws.com"
#   #     source_arn = module.secret_token.secret_arn
#   #   }
#   # ]

#   source_dir = "../../src/lambda/wms_refresh_token"
#   output_path = "../../src/lambda/wms_refresh_token/lambda_function.zip"
#   excludes = ["python/", ".python-version", ".dockerignore", "Dockerfile", "README.md", "lambda_function.zip", "python.zip"]
#   function_name = "func-hello-world-from-zip"
#   runtime = "python3.13"
#   handler = "handler.entrypoint"
#   publish = true

#   environment_variables = {
#     NEW_RELIC_ACCOUNT_ID = ""
#     NEW_RELIC_LAMBDA_HANDLER = "handler.entrypoint"
#     NEW_RELIC_LICENSE_KEY = ""
#     NEW_RELIC_TRUSTED_ACCOUNT_KEY = ""
#   }
# }

# # SecretsManager
# module "secret_token" {
#   source = "../../modules/secretsmanager"

#   name        = "wms/logiless"
#   enabled_rotation = true
#   rotation_lambda_arn = module.lambda_hello_world_from_image.lambda_function_arn
#   rotation_rules = {
#     automatically_after_days = 1
#     # duration = "1h"
#     # schedule_expression = "cron(*/10 * * * *)"
#   }
# }

# module "wms_secret_key" {
#   source      = "../../modules/ssm/parameter"
#   name        = "/wms/django/secret_key"
#   description = "Djangoのシークレットキー"
#   type        = "SecureString"
#   value       = "dummy"
# }


########################################################
# Lambda(Zip) の NewRelic統合の検証
########################################################

module "wms_refresh_token_env" {
  source = "../../modules/secretsmanager"

  name = "lambda/wms_refresh_token/env"

  create_secret_version = true
  secret_type           = "json"
  secret_string = {
    NEW_RELIC_ACCOUNT_ID          = "dummy"
    NEW_RELIC_LAMBDA_HANDLER      = "handler.entrypoint"
    NEW_RELIC_LICENSE_KEY         = "dummy"
    NEW_RELIC_TRUSTED_ACCOUNT_KEY = "dummy"
  }
}

data "aws_secretsmanager_secret_version" "wms_refresh_token_env" {
  secret_id = module.wms_refresh_token_env.secret_id
}

data "external" "wms_refresh_token_env" {
  program = ["echo", "${data.aws_secretsmanager_secret_version.wms_refresh_token_env.secret_string}"]
}

module "wms_refresh_token" {
  source        = "../../modules/lambda/image"
  service_name  = local.service_name
  function_name = "wms_refresh_token"
  image_uri     = "${module.ecr["wms_refresh_token"].repository_url}:latest"
  publish       = true

  environment_variables = {
    ENV = "dev"
  }
}


########################################################
# Cognitoユーザプールの検証
########################################################
module "cognito" {
  source = "../../modules/cognito"

  service_name        = local.service_name
  name                = "cognito"
  deletion_protection = "INACTIVE"
  auto_verified_attributes = ["email"]
  managed_login_version = 2  # マネージドログイン

  user_pool_schema = [
    {
      name                     = "email"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true
      required                 = true
      string_attribute_constraints = {
        min_length = "0"
        max_length = "2048"
      }
    },
    {
      name                     = "family_name"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true
      required                 = true
      string_attribute_constraints = {
        min_length = "0"
        max_length = "2048"
      }
    },
    {
      name                     = "given_name"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true
      required                 = true
      string_attribute_constraints = {
        min_length = "0"
        max_length = "2048"
      }
    },
    {
      name                     = "family_name_kana"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true
      required                 = false
      string_attribute_constraints = {
        min_length = "0"
        max_length = "255"
      }
    },
    {
      name                     = "given_name_kana"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true
      required                 = false
      string_attribute_constraints = {
        min_length = "0"
        max_length = "255"
      }
    },
    {
      name                     = "mail_magazine_flag"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true
      required                 = false
      string_attribute_constraints = {
        min_length = "1"
        max_length = "10"
      }
    },
    {
      name                     = "shop_id"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true
      required                 = false
      string_attribute_constraints = {
        min_length = "0"
        max_length = "50"
      }
    },
  ]

  password_policy = {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
    password_history_size            = 0
  }

  email_configuration = [
    {
      email_sending_account = "COGNITO_DEFAULT"
    }
  ]

  admin_create_user_config = {
    allow_admin_create_user_only = false
  }

  verification_message_template = {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  read_attributes = [
    "address",
    "birthdate",
    "custom:family_name_kana",
    "custom:given_name_kana",
    "custom:mail_magazine_flag",
    "custom:shop_id",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]

  write_attributes = [
    "address",
    "birthdate",
    "custom:family_name_kana",
    "custom:given_name_kana",
    "custom:mail_magazine_flag",
    "custom:shop_id",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]

  explicit_auth_flows = [
    "ALLOW_USER_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  prevent_user_existence_errors = "ENABLED"
  generate_secret                       = true
  cognito_domain_name                   = "auth.${data.aws_route53_zone.root.name}"
  cognito_custom_domain_certificate_arn = aws_acm_certificate.us_east_1.arn
  zone_id                               = data.aws_route53_zone.root.zone_id
  username_configuration_case_sensitive = false
}
