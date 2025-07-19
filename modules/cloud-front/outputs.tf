output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_aliases" {
  value = aws_cloudfront_distribution.main.aliases
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.main.arn
}

output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.main.hosted_zone_id
}
