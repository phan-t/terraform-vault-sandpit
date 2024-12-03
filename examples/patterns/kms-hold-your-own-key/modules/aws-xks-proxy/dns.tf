data "aws_route53_zone" "hashidemos" {
  name         = "${var.route53_sandbox_prefix}.sbx.hashidemos.io."
  private_zone = false
}

resource "aws_route53_record" "xks-proxy" {
  zone_id = data.aws_route53_zone.hashidemos.zone_id
  name    = "xks-proxy"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.xks-proxy.dns_name]
}