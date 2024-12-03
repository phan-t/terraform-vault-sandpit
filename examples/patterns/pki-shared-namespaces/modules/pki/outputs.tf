output "int_path" {
  value = vault_mount.pki-int.path
}

output "issuer_ref_int" {
  value = vault_pki_secret_backend_issuer.int.issuer_ref
}