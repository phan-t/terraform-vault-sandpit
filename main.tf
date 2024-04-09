locals {
  deployment_id = lower("${var.deployment_name}-${random_string.suffix.result}")
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}

resource "local_file" "consul-ent-license" {
  content  = var.vault_ent_license
  filename = "${path.root}/vault-ent-license.hclic"
}

// prerequisites

module "prerequisites" {
  source = "./modules/prerequisites"

  deployment_id          = local.deployment_id
  route53_sandbox_prefix = var.aws_route53_sandbox_prefix
}

// amazon web services (aws) infrastructure

module "aws_prerequisites" {
  source = "github.com/hashicorp-modules/terraform-aws-vault-prerequisites?ref=v1.0.1"
  
  common_tags               = var.aws_common_tags
  friendly_name_prefix      = local.deployment_id
  create_vpc                = true
  vpc_enable_ssm            = true
  create_secrets            = true
  secretsmanager_secrets    = var.aws_secretsmanager_secrets
  create_kms                = true
  create_iam_resources      = true
  iam_resources             = var.aws_iam_resources
  create_s3_buckets         = true
  s3_buckets                = var.aws_s3_buckets
  create_log_group          = true
  ssh_keypair_name          = local.deployment_id
  create_lb                 = true
  create_lb_security_groups = true
  lb_sg_rules_details       = var.aws_lb_sg_rules
  route53_zone_name         = "${var.aws_route53_sandbox_prefix}.sbx.hashidemos.io"
  route53_failover_record   = var.aws_route53_failover_record
}

// hashicorp self-managed vault

module "vault" {
  source = "github.com/hashicorp-modules/terraform-aws-vault?ref=v1.0.0"

  permit_all_egress         = true
  vpc_id                    = module.aws_prerequisites.vpc_id
  friendly_name_prefix      = local.deployment_id
  common_tags               = var.aws_common_tags
  ssh_key_pair              = module.aws_prerequisites.ssh_keypair_name
  kms_key_arn               = module.aws_prerequisites.kms_key_alias_arn
  iam_instance_profile      = module.aws_prerequisites.iam_role_name
  vault_version             = var.vault_version
  asg_max_size              = 6
  asg_instance_count        = 3
  asg_hook_value            = module.aws_prerequisites.asg_hook_value
  instance_size             = "m5.large"
  lb_type                   = module.aws_prerequisites.lb_type
  ec2_subnet_ids            = module.aws_prerequisites.private_subnet_ids
  vault_secrets_arn         = module.aws_prerequisites.vault_secrets_arn
  vault_cert_secret_arn     = module.aws_prerequisites.cert_pem_secret_arn
  vault_privkey_secret_arn  = module.aws_prerequisites.cert_pem_private_key_secret_arn
  ca_bundle_secret_arn      = module.aws_prerequisites.ca_certificate_bundle_secret_arn
  vault_hostname            = module.aws_prerequisites.route53_failover_fqdn
  lb_tg_arns                = module.aws_prerequisites.lb_tg_arns
  cloudwatch_log_group_name = module.aws_prerequisites.cloudwatch_log_group_name
}