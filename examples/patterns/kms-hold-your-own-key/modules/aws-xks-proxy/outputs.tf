output "public_fqdn" {
  description = "public fqdn"
  value       = aws_instance.xks-proxy.public_dns
}