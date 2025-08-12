################################################################################
# Lambda関数のCloudWatchロググループ
################################################################################
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.service_name}-func-${var.function_name}"
  log_group_class   = var.log_group_class
  retention_in_days = var.retention_in_days
}


################################################################################
# Lambda関数の実行ロール
################################################################################
resource "aws_iam_role" "main" {
  count = var.create_lambda_execution_role ? 1 : 0

  name = "${var.service_name}-role-${var.function_name}-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.lambda_execution_role_tags,
    { Name = "${var.service_name}-role-${var.function_name}-execution" }
  )
}

resource "aws_iam_policy" "main" {
  count = var.create_lambda_execution_role && var.lambda_execution_role_policy != null ? 1 : 0

  name   = "${var.service_name}-policy-${var.function_name}-execution"
  policy = jsonencode(var.lambda_execution_role_policy)

  tags = merge(
    var.lambda_execution_role_policy_tags,
    { Name = "${var.service_name}-policy-${var.function_name}-execution" }
  )
}

resource "aws_iam_role_policy_attachment" "main" {
  count = var.create_lambda_execution_role && var.lambda_execution_role_policy != null ? 1 : 0

  role       = aws_iam_role.main[0].name
  policy_arn = aws_iam_policy.main[0].arn
}

resource "aws_iam_policy" "cloudwatch_logs" {
  count = var.create_lambda_execution_role ? 1 : 0

  name = "${var.service_name}-policy-${var.function_name}-cloudwatch-logs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_cloudwatch_log_group.main.arn,
          "${aws_cloudwatch_log_group.main.arn}:*"
        ]
      }
    ]
  })

  tags = {
    Name = "${var.service_name}-policy-${var.function_name}-cloudwatch-logs"
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  count = var.create_lambda_execution_role != null ? 1 : 0

  role       = aws_iam_role.main[0].name
  policy_arn = aws_iam_policy.cloudwatch_logs[0].arn
}


################################################################################
# Lambda関数
################################################################################
resource "aws_lambda_function" "main" {
  function_name    = "${var.service_name}-func-${var.function_name}"
  package_type     = "Image"
  description      = var.description
  role             = var.create_lambda_execution_role ? aws_iam_role.main[0].arn : var.lambda_execution_role_arn
  publish          = var.publish
  memory_size      = var.memory_size
  timeout          = var.timeout
  image_uri        = var.image_uri

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids                  = vpc_config.value.subnet_ids
      security_group_ids          = vpc_config.value.security_group_ids
      ipv6_allowed_for_dual_stack = vpc_config.value.ipv6_allowed_for_dual_stack
    }
  }

  lifecycle {
    ignore_changes = [ image_uri ]
  }
}

resource "aws_lambda_permission" "main" {
  for_each = { for idx, perm in var.lambda_permissions : idx => perm }

  action                 = each.value.action
  function_name          = each.value.function_name
  principal              = each.value.principal
  source_arn             = lookup(each.value, "source_arn", null)
  qualifier              = lookup(each.value, "qualifier", null)
  statement_id           = lookup(each.value, "statement_id", null)
  statement_id_prefix    = lookup(each.value, "statement_id_prefix", null)
  function_url_auth_type = lookup(each.value, "function_url_auth_type", null)
  principal_org_id       = lookup(each.value, "principal_org_id", null)
  source_account         = lookup(each.value, "source_account", null)
}
