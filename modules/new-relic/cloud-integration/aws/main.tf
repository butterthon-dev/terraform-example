locals {
  newrelic_urls = {
    US = "https://aws-api.newrelic.com/cloudwatch-metrics/v1"
    EU = "https://aws-api.eu01.nr-data.net/cloudwatch-metrics/v1"
  }
}

########################################################
# 1. New Relicと対象プロジェクト間でのIAMロールを作成する
########################################################

data "aws_iam_policy_document" "newrelic_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["754728514883"] # New RelicのAWSアカウントID（固定）
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.new_relic_account_id]
    }
  }
}

resource "aws_iam_role" "newrelic_aws_role" {
  name               = "${var.service_name}-${var.env}-role-newrelic"
  description        = "New Relic AWS integration role for Dev"
  assume_role_policy = data.aws_iam_policy_document.newrelic_assume_policy.json
}

resource "aws_iam_policy" "newrelic_aws_permissions" {
  name        = "${var.service_name}-${var.env}-policy-newrelic"
  description = ""
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "budgets:ViewBudget",
        "cloudtrail:LookupEvents",
        "config:BatchGetResourceConfig",
        "config:ListDiscoveredResources",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeVpcs",
        "ec2:DescribeNatGateways",
        "ec2:DescribeVpcEndpoints",
        "ec2:DescribeSubnets",
        "ec2:DescribeNetworkAcls",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcPeeringConnections",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeVpnConnections",
        "health:DescribeAffectedEntities",
        "health:DescribeEventDetails",
        "health:DescribeEvents",
        "tag:GetResources",
        "xray:BatchGet*",
        "xray:Get*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "newrelic_aws_policy_attach" {
  role       = aws_iam_role.newrelic_aws_role.name
  policy_arn = aws_iam_policy.newrelic_aws_permissions.arn
}


########################################################
# 2. New Relicと対象AWSアカウントの間でMetric Streams連携を行う
########################################################

resource "newrelic_cloud_aws_link_account" "newrelic_cloud_integration_push" {
  account_id             = var.new_relic_account_id
  arn                    = aws_iam_role.newrelic_aws_role.arn
  metric_collection_mode = "PUSH"
  name                   = "${var.new_relic_account_name} Push"  # ${var.service_name}-${var.env}-newrelic
  depends_on             = [aws_iam_role_policy_attachment.newrelic_aws_policy_attach]
}


########################################################
# 3. New Relic Ingest License Keyを作成する
########################################################

resource "newrelic_api_access_key" "newrelic_aws_access_key" {
  account_id  = var.new_relic_account_id
  key_type    = "INGEST"
  ingest_type = "LICENSE"
  name        = "${var.service_name}-${var.env}-ingest-license-key"
  notes       = "AWS Cloud Integrations Firehost Key"
}


########################################################
# 4. AWS Kinesis Data FirehoseからNew Relicに対するデータ送信設定を行う
########################################################

resource "aws_iam_role" "firehose_newrelic_role" {
  # name = "firehose_newrelic_role"
  name = "${var.service_name}-${var.env}-role-firehose-newrelic"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "random_string" "s3-bucket-name" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "newrelic_aws_bucket" {
  bucket = "${var.service_name}-${var.env}-s3-newrelic-${random_string.s3-bucket-name.id}"
}

resource "aws_s3_bucket_acl" "newrelic_aws_bucket_acl" {
  bucket = aws_s3_bucket.newrelic_aws_bucket.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.newrelic_aws_bucket_ownership_controls]
}

resource "aws_s3_bucket_ownership_controls" "newrelic_aws_bucket_ownership_controls" {
  bucket = aws_s3_bucket.newrelic_aws_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "newrelic_firehose_delivery_stream" {
  name        = "${var.service_name}-${var.env}-kfds-newrelic"
  destination = "http_endpoint"

  http_endpoint_configuration {
    url                = local.newrelic_urls[var.newrelic_account_region]
    name               = "New Relic"
    access_key         = newrelic_api_access_key.newrelic_aws_access_key.key
    buffering_size     = 1
    buffering_interval = 60
    role_arn           = aws_iam_role.firehose_newrelic_role.arn
    s3_backup_mode     = "FailedDataOnly"

    s3_configuration {
      role_arn           = aws_iam_role.firehose_newrelic_role.arn
      bucket_arn         = aws_s3_bucket.newrelic_aws_bucket.arn
      buffering_size     = 10
      buffering_interval = 400
      compression_format = "GZIP"
    }

    request_configuration {
      content_encoding = "GZIP"
    }
  }
}


########################################################
# 5. AWS CloudWatch Metric Streamsを設定する
########################################################

resource "aws_iam_role" "metric_stream_to_firehose" {
  # name = "metric_stream_to_firehose_role"
  name = "${var.service_name}-${var.env}-role-metric-stream-to-firehose"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "streams.metrics.cloudwatch.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "metric_stream_to_firehose" {
  name = "${var.service_name}-${var.env}-policy-metric-stream-to-firehose"
  role = aws_iam_role.metric_stream_to_firehose.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource": "${aws_kinesis_firehose_delivery_stream.newrelic_firehose_delivery_stream.arn}"
        }
    ]
}
EOF
}

resource "aws_cloudwatch_metric_stream" "newrelic_metric_stream" {
  name          = "${var.service_name}-${var.env}-cwms-newrelic"
  role_arn      = aws_iam_role.metric_stream_to_firehose.arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.newrelic_firehose_delivery_stream.arn
  output_format = "opentelemetry0.7"

  dynamic "include_filter" {
    for_each = var.metrics_include_filters
    content {
      namespace = include_filter.value.namespace
      metric_names = include_filter.value.metric_names
    }
  }

  dynamic "exclude_filter" {
    for_each = var.metrics_exclude_filters
    content {
      namespace = exclude_filter.value.namespace
      metric_names = exclude_filter.value.metric_names
    }
  }
}
