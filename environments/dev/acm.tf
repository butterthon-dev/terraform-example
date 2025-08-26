# ap-northeast-1のワイルドカード証明書
resource "aws_acm_certificate" "main" {
  domain_name               = data.aws_route53_zone.root.name
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"
  subject_alternative_names = ["*.${data.aws_route53_zone.root.name}"]
}

resource "aws_route53_record" "main" {
  for_each = {
    for d in aws_acm_certificate.main.domain_validation_options : d.domain_name => {
      name  = d.resource_record_name
      type  = d.resource_record_type
      value = d.resource_record_value
    }
  }

  zone_id         = data.aws_route53_zone.root.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.value]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn
  validation_record_fqdns = [
    for record in aws_route53_record.main : record.fqdn
  ]
}

# us-east-1のワイルドカード証明書
resource "aws_acm_certificate" "us_east_1" {
  provider = aws.us_east_1

  domain_name               = data.aws_route53_zone.root.name
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"
  subject_alternative_names = ["*.${data.aws_route53_zone.root.name}"]
}

resource "aws_route53_record" "us_east_1" {
  for_each = {
    for d in aws_acm_certificate.us_east_1.domain_validation_options : d.domain_name => {
      name  = d.resource_record_name
      type  = d.resource_record_type
      value = d.resource_record_value
    }
  }

  zone_id         = data.aws_route53_zone.root.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.value]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "us_east_1" {
  provider = aws.us_east_1

  certificate_arn = aws_acm_certificate.us_east_1.arn
  validation_record_fqdns = [
    for record in aws_route53_record.us_east_1 : record.fqdn
  ]
}
