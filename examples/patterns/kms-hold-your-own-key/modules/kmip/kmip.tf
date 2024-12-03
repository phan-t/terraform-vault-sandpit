locals {
  kmip_credentials = jsondecode(data.http.kmip_credentials.response_body)
}

resource "vault_kmip_secret_backend" "hyok" {
  path                        = "kmip"
  description                 = "kmip hyok mount"
  listen_addrs                = ["0.0.0.0:5696"]
  server_hostnames            = ["localhost", "vault.tphan.sbx.hashidemos.io"]
  # tls_ca_key_type             = "rsa"
  # tls_ca_key_bits             = 4096
  # default_tls_client_key_type = "rsa"
  # default_tls_client_key_bits = 4096
  # default_tls_client_ttl      = 86400
}

resource "vault_kmip_secret_scope" "hyok" {
  path  = vault_kmip_secret_backend.hyok.path
  scope = "hyok"
  force = true
}

resource "vault_kmip_secret_role" "hyok_admin" {
  path                     = vault_kmip_secret_scope.hyok.path
  scope                    = vault_kmip_secret_scope.hyok.scope
  role                     = "admin"
  # tls_client_key_type      = "ec"
  # tls_client_key_bits      = 256
  operation_all            = true
}

// no terraform resource for kmip credential generation

data "http" "kmip_credentials" {
  url = "${var.vault_address}v1/kmip/scope/hyok/role/admin/credential/generate"
  method = "POST"
  insecure = true

  request_headers = {
    X-Vault-Token = var.vault_token
  }

  depends_on = [ 
    vault_kmip_secret_role.hyok_admin 
  ]
}

resource "local_file" "kmip_credentials_ca" {
  content = "${local.kmip_credentials.data.ca_chain[0]}\n${local.kmip_credentials.data.ca_chain[1]}"
  filename = "${path.root}/configs/kmip_credentials_ca.pem"
}

resource "local_file" "kmip_credentials_cert" {
  content = local.kmip_credentials.data.certificate
  filename = "${path.root}/configs/kmip_credentials_cert.pem"
}