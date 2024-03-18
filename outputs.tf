// generic outputs

output "deployment_id" {
  description = "deployment identifier"
  value       = local.deployment_id
}

// amazon web services (aws) outputs

// hashicorp self-managed vault ouputs

output "vault_public_fqdn" {
  description = "vault public fqdn"
  value       = "https://${module.aws_prerequisites.route53_failover_fqdn}:8200/"
}