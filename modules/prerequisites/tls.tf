// self-signed root certificate authority
resource "tls_private_key" "ca-key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "ca-cert" {
  private_key_pem   = tls_private_key.ca-key.private_key_pem
  is_ca_certificate = true

  subject {
    common_name  = "ca.vault.${var.route53_sandbox_prefix}.sbx.hashidemos.io"
    organization = "hashicorp"
  }

  validity_period_hours = 8760 // 365 days

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

// server(s) certificate

resource "tls_private_key" "server-key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "server-cert" {
  private_key_pem = tls_private_key.server-key.private_key_pem

  subject {
    common_name  = "*.vault.${var.route53_sandbox_prefix}.sbx.hashidemos.io"
    organization = "hashicorp"
  }

  dns_names = [
    "vault.${var.route53_sandbox_prefix}.sbx.hashidemos.io",
    "localhost"
  ]

  ip_addresses = [
    "127.0.0.1",
  ]
}

resource "tls_locally_signed_cert" "server-signed-cert" {
  cert_request_pem = tls_cert_request.server-cert.cert_request_pem
  ca_private_key_pem = tls_private_key.ca-key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca-cert.cert_pem

  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "server_auth",
  ]

  validity_period_hours = 720 // 30-days
}

resource "local_file" "ca-cert" {
  content  = tls_self_signed_cert.ca-cert.cert_pem
  filename = "${path.module}/tls/ca-cert.pem"
}

resource "local_file" "server-cert" {
  content  = tls_locally_signed_cert.server-signed-cert.cert_pem
  filename = "${path.module}/tls/server-cert.pem"
}

resource "local_file" "server-key" {
  content  = nonsensitive(tls_private_key.server-key.private_key_pem)
  filename = "${path.module}/tls/server-key.pem"
}