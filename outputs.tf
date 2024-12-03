// generic outputs

output "deployment_id" {
  description = "deployment identifier"
  value       = local.deployment_id
}

// amazon web services (aws) outputs

output "aws_region" {
  description = "aws region"
  value       = var.aws_region
}

output "aws_lb_arn" {
  description = "aws load balancer arn"
  value       = module.aws_prerequisites.lb_arn
}

// hashicorp self-managed vault ouputs

output "vault_public_fqdn" {
  description = "vault public fqdn"
  value       = "https://${module.aws_prerequisites.route53_failover_fqdn}:8200/"
}