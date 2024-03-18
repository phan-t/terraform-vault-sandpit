// internal root ca

resource "vault_mount" "pki-root" {
  path        = "pki-root"
  type        = "pki"
  description = "root pki mount"

  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 315360000
}

resource "vault_pki_secret_backend_root_cert" "root" {
   backend     = vault_mount.pki-root.path
   type        = "internal"
   common_name = "sandpit.com"
   ttl         = 315360000
   issuer_name = "root"
}

resource "vault_pki_secret_backend_issuer" "root" {
   backend                        = vault_mount.pki-root.path
   issuer_ref                     = vault_pki_secret_backend_root_cert.root.issuer_id
   issuer_name                    = vault_pki_secret_backend_root_cert.root.issuer_name
   revocation_signature_algorithm = "SHA256WithRSA"
}

# resource "vault_pki_secret_backend_role" "root" {
#    backend          = vault_mount.pki-root.path
#    name             = "root"
#    ttl              = 86400
#    allow_ip_sans    = true
#    key_type         = "rsa"
#    key_bits         = 4096
#    allowed_domains  = ["sandpit.com"]
#    allow_subdomains = true
#    allow_any_name   = true
# }

# resource "vault_pki_secret_backend_config_urls" "root" {
#    backend = vault_mount.pki-root.path
#    issuing_certificates    = ["http://localhost:8200/v1/pki/ca"]
#    crl_distribution_points = ["http://localhost:8200/v1/pki/crl"]
# }

// internal intermediate ca

resource "vault_mount" "pki-int" {
   path        = "pki-int"
   type        = "pki"
   description = "intermediate pki mount"

   default_lease_ttl_seconds = 86400
   max_lease_ttl_seconds     = 157680000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "int" {
   backend     = vault_mount.pki-int.path
   type        = "internal"
   common_name = "sandpit.com intermediate certificate authority"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "int" {
   backend     = vault_mount.pki-root.path
   common_name = "sandpit.com intermediate certificate authority"
   csr         = vault_pki_secret_backend_intermediate_cert_request.int.csr
   format      = "pem_bundle"
   ttl         = 15480000
   issuer_ref  = vault_pki_secret_backend_root_cert.root.issuer_id
}

resource "vault_pki_secret_backend_intermediate_set_signed" "int" {
   backend     = vault_mount.pki-int.path
   certificate = vault_pki_secret_backend_root_sign_intermediate.int.certificate
}

resource "vault_pki_secret_backend_issuer" "int" {
  backend     = vault_mount.pki-int.path
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.int.imported_issuers[0]
  issuer_name = "sandpit-dot-com-intermediate"
}