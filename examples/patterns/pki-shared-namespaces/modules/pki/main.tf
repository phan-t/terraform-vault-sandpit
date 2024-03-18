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