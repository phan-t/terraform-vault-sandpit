output "xks_proxy_public_fqdn" {
  description = "public fqdn of xks-proxy"
  value       = module.aws-xks-proxy.public_fqdn
}