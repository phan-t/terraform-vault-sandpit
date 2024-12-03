resource "aws_acm_certificate" "xks-proxy" {
  domain_name       = aws_route53_record.xks-proxy.fqdn
  validation_method = "DNS"
}

# resource "aws_route53_record" "xks-proxy-cert-validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.xks-proxy.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.hashidemos.zone_id
# }

resource "aws_route53_record" "xks-proxy-cert-validation" {
  zone_id = data.aws_route53_zone.hashidemos.zone_id
  name    = tolist(aws_acm_certificate.xks-proxy.domain_validation_options).0.resource_record_name
  type    = tolist(aws_acm_certificate.xks-proxy.domain_validation_options).0.resource_record_type
  ttl     = 60
  records = [tolist(aws_acm_certificate.xks-proxy.domain_validation_options).0.resource_record_value]
}

resource "aws_acm_certificate_validation" "xks-proxy" {
  certificate_arn         = aws_acm_certificate.xks-proxy.arn
  validation_record_fqdns = [aws_route53_record.xks-proxy-cert-validation.fqdn]
}