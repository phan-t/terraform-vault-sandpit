resource "aws_lb_target_group" "xks-proxy" {
  name     = "${var.deployment_id}-xks-proxy-tg"
  port     = 8000
  protocol = "TCP"
  vpc_id   = data.aws_vpc.this.id
}

resource "aws_lb_target_group_attachment" "xks-proxy" {
  target_group_arn = aws_lb_target_group.xks-proxy.arn
  target_id        = aws_instance.xks-proxy.id
  port             = 8000
}

resource "aws_lb" "xks-proxy" {
  name               = "${var.deployment_id}-xks-proxy"
  internal           = false
  load_balancer_type = "network"
  # security_groups    = [module.sg-xks-proxy-lb.security_group_id]
  subnets            = data.aws_subnets.public.ids

  tags = {
    Name  = "${var.deployment_id}-xks-proxy"
  }
}

resource "aws_lb_listener" "xks-proxy" {
  load_balancer_arn = aws_lb.xks-proxy.arn
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.xks-proxy.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.xks-proxy.arn
  }
}
