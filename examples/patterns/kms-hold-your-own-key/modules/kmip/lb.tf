data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["*${var.deployment_id}*"]
  }
}

resource "aws_lb_target_group" "kmip" {
  name     = "${var.deployment_id}-vault-kmip-tg"
  port     = 5696
  protocol = "TCP"
  vpc_id   = data.aws_vpc.this.id
}

resource "aws_lb_listener" "kmip" {
  load_balancer_arn = var.aws_lb_arn
  port              = "5696"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kmip.arn
  }
}