variable "service_name" {
  description = "サービス名（例: 'operation', 'cart', 'wms'）"
  type        = string
}

variable "env" {
  description = "環境（例: 'dev', 'prod'）"
  type        = string
}

variable "region" {
  description = "リージョン"
  type        = string
  default     = "ap-northeast-1"
}


################################################################################
# タスク実行ロール
################################################################################

variable "create_task_execution_role" {
  type        = bool
  description = "ECSタスク実行ロールを作成するかどうか"
  default     = true
}

variable "task_execution_role_policy" {
  type = object({
    Version = string
    Statement = list(object({
      Effect   = string
      Action   = list(string)
      Resource = list(string)
    }))
  })
  description = "ECSタスク実行ロールのポリシー"
  default = {
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },

      # Pulled from AmazonECSTaskExecutionRolePolicy
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },

      # AmazonEC2ContainerRegistryReadOnly
      {
        Effect = "Allow"
        Action = [
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings"
        ]
        Resource = ["*"]
      }
    ]
  }
}

variable "task_execution_role_arn" {
  type        = string
  description = "ECSタスク定義のタスク実行ロールARN"
  default     = null
}

variable "task_execution_role_tags" {
  type        = map(string)
  description = "タスク実行ロールのタグ"
  default     = {}
}

variable "task_execution_role_policy_tags" {
  type        = map(string)
  description = "タスク実行ロールポリシーのタグ"
  default     = {}
}


################################################################################
# タスクロール
################################################################################

variable "create_task_role" {
  type        = bool
  description = "ECSタスクロールを作成するかどうか"
  default     = true
}

variable "task_role_policy" {
  type = object({
    Version = string
    Statement = list(object({
      Effect   = string
      Action   = list(string)
      Resource = list(string)
    }))
  })
  description = "ECSタスクロールのポリシー"
  default     = null
}

variable "task_role_arn" {
  type        = string
  description = "ECSタスク定義のタスクロールARN"
  default     = null
}

variable "task_role_tags" {
  type        = map(string)
  description = "タスクロールのタグ"
  default     = {}
}

variable "task_role_policy_tags" {
  type        = map(string)
  description = "タスクロールポリシーのタグ"
  default     = {}
}


################################################################################
# セキュリティグループ
################################################################################
variable "sg_description" {
  type        = string
  description = "セキュリティグループの説明"
  default     = "ALB"
}

variable "egress_rules" {
  type = list(object({
    description     = optional(string)
    security_group_ids = optional(list(string))
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  description = "アウトバウンドルール"
  default = [{
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
  }]
}

variable "ingress_rules" {
  type = list(object({
    description     = optional(string)
    security_group_ids = optional(list(string))
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  description = "インバウンドルール"
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "security_group_tags" {
  type        = map(string)
  description = "セキュリティグループのタグ"
  default     = {}
}


################################################################################
# ECSクラスター
################################################################################
variable "ecs_cluster_name" {
  description = "ecs cluster name"
  type        = string
}


################################################################################
# Service Discovery
################################################################################
variable "enabled_service_discovery" {
  type        = bool
  description = "Service Discoveryを有効にするかどうか"
  default     = false
}

variable "service_discovery_name" {
  type        = string
  description = "Service Discoveryの名前"
  default     = null
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "Service Discoveryの名前空間ID"
  default     = null
}


################################################################################
# ECSタスク定義
################################################################################

variable "cloudwatch_log_group_tags" {
  type        = map(string)
  description = "CloudWatchロググループのタグ"
  default     = {}
}

variable "requires_compatibilities" {
  type        = list(string)
  description = "ECSタスク定義の互換性"
  default     = ["FARGATE"]
}

variable "network_mode" {
  type        = string
  description = "ECSタスク定義のネットワークモード"
  default     = "awsvpc"
}

variable "task_cpu" {
  type        = number
  description = "ECSタスク定義のCPU"
  default     = 256
}

variable "task_memory" {
  type        = number
  description = "ECSタスク定義のメモリ"
  default     = 512
}

variable "container_definitions" {
  type = list(object({
    name  = string
    image = string
    portMappings = optional(list(object({
      name          = string
      containerPort = number
      protocol      = string
    })))
    environment = optional(list(object({
      name  = string
      value = string
    })))
    essential              = bool
    readonlyRootFilesystem = optional(bool)
    # enableCloudwatchLogging = bool
  }))
  description = "ECSタスク定義のコンテナ定義"
}

variable "ecs_task_definition_tags" {
  type        = map(string)
  description = "ECSタスク定義のタグ"
  default     = {}
}


################################################################################
# ECSサービス
################################################################################

variable "ecs_service_name" {
  type        = string
  description = "ECSサービス名"
}

variable "desired_count" {
  type        = number
  description = "ECSサービスのタスク数"
  default     = 1
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "デプロイ中にサービス内で実行され、正常な状態を維持する必要がある実行中のタスク数の下限(desired_countに対する割合)"
  default     = 100
}

variable "deployment_maximum_percent" {
  type        = number
  description = "デプロイ中にサービス内で実行可能なタスク数の上限(desired_countに対する割合)"
  default     = 200
}

variable "platform_version" {
  type        = string
  description = "ECSサービスのプラットフォームバージョン"
  default     = "LATEST"
}

variable "scheduling_strategy" {
  type        = string
  description = "ECSサービスのスケジューリング戦略"
  default     = "REPLICA"
}

variable "service_connect_configuration" {
  type = object({
    enabled = bool
    service = optional(object({
      client_alias = optional(object({
        dns_name = string
        port     = number
      }))
      discovery_name        = optional(string)
      ingress_port_override = optional(number)
      port_name             = string
      timeout               = optional(number)
    }))
  })
  description = "ECSサービスのサービスコネクト設定"
  default     = null
}

variable "network_configuration" {
  type = object({
    subnet_ids       = list(string)
    assign_public_ip = bool
  })
  description = "ECSサービスのネットワーク設定"
  default     = null
}

variable "load_balancer" {
  type = object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  })
  description = "ECSサービスのロードバランサー設定"
  default     = null
}

variable "deployment_controller" {
  type = object({
    type = string
  })
  description = "ECSサービスのデプロイコントローラー設定"
  default = {
    type = "ECS"
  }
}

variable "deployment_circuit_breaker" {
  type = object({
    enable   = bool
    rollback = bool
  })
  description = "ECSサービスのサービスレジストリー設定"
  default = {
    enable   = true
    rollback = true
  }
}

variable "ecs_service_tags" {
  type        = map(string)
  description = "ECSサービスのタグ"
  default     = {}
}