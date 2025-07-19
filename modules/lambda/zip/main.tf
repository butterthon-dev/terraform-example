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


################################################################################
# Lambdaレイヤー
################################################################################
resource "terraform_data" "lambda_layer" {
  triggers_replace = {
    "code_diff" = filebase64("${var.source_dir}/requirements.txt")
  }

  # PythonのLambdaレイヤーは関数を実行するコンテナの/opt/pythonに展開される必要があるため、フォルダ名はpythonにする必要がある。
  provisioner "local-exec" {
    command = "pip3 install -r ${var.source_dir}/requirements.txt -t ${var.source_dir}/python"
  }

  provisioner "local-exec" {
    command = "cd ${var.source_dir} && zip -r python.zip python/"
  }
}

resource "aws_lambda_layer_version" "main" {
  layer_name = "${var.service_name}-layer-${var.function_name}"
  filename = "${var.source_dir}/python.zip"
  source_code_hash = terraform_data.lambda_layer.triggers_replace["code_diff"]
  compatible_runtimes = [var.runtime]
  depends_on = [ terraform_data.lambda_layer ]
}


################################################################################
# Lambda関数
################################################################################
data "archive_file" "lambda_source" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = var.output_path
  excludes    = var.excludes
}

resource "aws_lambda_function" "main" {
  function_name    = "${var.service_name}-func-${var.function_name}"
  package_type     = "Zip"
  description      = var.description
  role             = var.create_lambda_execution_role ? aws_iam_role.main[0].arn : var.lambda_execution_role_arn
  publish          = var.publish
  memory_size      = var.memory_size
  timeout          = var.timeout
  runtime          = var.runtime
  filename         = data.archive_file.lambda_source.output_path
  handler          = var.handler
  source_code_hash = data.archive_file.lambda_source.output_base64sha256
  layers = [aws_lambda_layer_version.main.arn]

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids                  = vpc_config.value.subnet_ids
      security_group_ids          = vpc_config.value.security_group_ids
      ipv6_allowed_for_dual_stack = vpc_config.value.ipv6_allowed_for_dual_stack
    }
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
