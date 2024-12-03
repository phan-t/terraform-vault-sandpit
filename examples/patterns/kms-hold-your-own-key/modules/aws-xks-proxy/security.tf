data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.deployment_id}-*"]
  }
}

module "sg-xks-proxy" {
  source = "terraform-aws-modules/security-group/aws"
  version     = "4.9.0"

  name        = "${var.deployment_id}-xks-proxy"
  vpc_id      = data.aws_vpc.this.id

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      description = "xks-proxy-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "any-any"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "sg-xks-proxy-lb" {
  source = "terraform-aws-modules/security-group/aws"
  version     = "4.9.0"

  name        = "${var.deployment_id}-xks-proxy"
  vpc_id      = data.aws_vpc.this.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "xks-proxy-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "any-any"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}