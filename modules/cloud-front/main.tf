resource "aws_s3_bucket_policy" "main" {
  bucket = var.bucket_id
  policy = var.bucket_policy
}

resource "aws_cloudfront_origin_access_control" "main" {
  name = var.oac_name
  description = var.oac_description
  origin_access_control_origin_type = var.oac_type
  signing_behavior = var.oac_signing_behavior
  signing_protocol = var.oac_signing_protocol
}

resource "aws_cloudfront_distribution" "main" {
  enabled = true
  http_version = "http2"
  is_ipv6_enabled = true
  price_class = "PriceClass_All"
  retain_on_delete = false

  aliases = []

  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id = var.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    connection_attempts = 3
    connection_timeout = 10
  }

  viewer_certificate {
    # デフォルトの証明書を使用
    cloudfront_default_certificate = true
    acm_certificate_arn = null
    # ssl_support_method = "sni-only"
    # minimum_protocol_version = "TLSv1.2_2021"
    minimum_protocol_version = "TLSv1"
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    compress = true
    default_ttl = 3600
    max_ttl = 86400
    min_ttl = 0
    smooth_streaming = false
    target_origin_id = var.bucket_id
    viewer_protocol_policy = "allow-all"

    forwarded_values {
        query_string = false
        cookies {
            forward = "none"
        }
    }
  }

  restrictions {
    geo_restriction {
        restriction_type = "none"
    }
  }
}
