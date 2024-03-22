resource "vault_pki_secret_backend_role" "this" {
   backend          = var.path_pki_int
   issuer_ref       = var.issuer_ref_int
   name             = "sandpit-dot-com"
   ttl              = 86400
   max_ttl          = 2592000
   allow_ip_sans    = true
   key_type         = "rsa"
   key_bits         = 4096
   allowed_domains  = ["sandpit.com"]
   allow_subdomains = true
   # allow_any_name   = true
}