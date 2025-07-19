# data "aws_iam_policy_document" "private_images_policy" {
#   statement {
#     actions = [
#       "s3:GetObject",
#       "s3:PutObject",
#       "s3:DeleteObject"
#     ]
#     resources = [
#       module.private_images.bucket_arn,
#       "${module.private_images.bucket_arn}/*"
#     ]
#     principals {
#       type = "AWS"
#       identifiers = ["184321346292"]
#     }
#     effect = "Allow"
#   }

#   statement {
#     actions = [
#       "s3:GetObject"
#     ]
#     resources = [
#       module.private_images.bucket_arn,
#       "${module.private_images.bucket_arn}/*"
#     ]
#     principals {
#       type = "Service"
#       identifiers = ["cloudfront.amazonaws.com"]
#     }
#     effect = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceArn"
#       values = [
#         module.cloudfront_private_images.cloudfront_arn
#       ]
#     }
#   }

#   // CloudFront経由のtmpフォルダへのアクセスを拒否するステートメント
#   statement {
#     actions = [
#       "s3:GetObject"
#     ]
#     resources = [
#       "${module.private_images.bucket_arn}/tmp",
#       "${module.private_images.bucket_arn}/tmp/*"
#     ]
#     principals {
#       type = "Service"
#       identifiers = ["cloudfront.amazonaws.com"]
#     }
#     effect = "Deny"

#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceArn"
#       values = [
#         module.cloudfront_private_images.cloudfront_arn
#       ]
#     }
#   }
# }

# // LambdaのIAMロール
# resource "aws_iam_policy" "lambda-policy" {
#   name = "lambda-policy"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "ecr:*"
#         ],
#         Resource = "*",
#         Effect   = "Allow"
#       }
#     ]
#   })
# }
# resource "aws_iam_policy_attachment" "name" {
#   name = "lambda-policy-attachment"
#   roles = [aws_iam_role.lambda_role.name]
#   policy_arn = aws_iam_policy.lambda-policy.arn
# }
