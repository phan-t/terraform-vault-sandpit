// Create namespace

resource "vault_namespace" "this" {  
  path = var.app_id
}

// Create auth method

resource "vault_auth_backend" "userpass" {
  namespace  = vault_namespace.this.path
  path       = "userpass"
  type       = "userpass"
}

// Config entity

resource "vault_generic_endpoint" "config" {
  namespace            = vault_namespace.this.path
  path                 = "auth/userpass/users/test-config"
  ignore_absent_fields = true

  data_json = <<EOT
{
"policies": ["default"],
"password": "my-long-password"
}
EOT

  depends_on = [
    vault_auth_backend.userpass
  ]
}

resource "vault_identity_entity" "config" {
  namespace = vault_namespace.this.path
  name      = "config-${var.app_id}-sandpit-dot-com"

  metadata  = {
    pki-int-shared-role = "${var.app_id}-sandpit-dot-com"
  }
}

resource "vault_identity_entity_alias" "config" {
  namespace      = vault_namespace.this.path
  name           = "test-config"
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.config.id

  depends_on = [ 
  vault_identity_entity.config
  ]
}

resource "vault_identity_group_member_entity_ids" "config" {
  namespace         = "root"
  member_entity_ids = [vault_identity_entity.config.id]
  group_id          = var.config_identity_group_id
  exclusive         = false
}

// Issuance entity

resource "vault_generic_endpoint" "issuance" {
  namespace            = vault_namespace.this.path
  path                 = "auth/userpass/users/test-issuance"
  ignore_absent_fields = true

  data_json = <<EOT
{
"policies": ["default"],
"password": "my-long-password"
}
EOT

  depends_on = [
    vault_auth_backend.userpass
  ]
}

resource "vault_identity_entity" "issuance" {
  namespace = vault_namespace.this.path
  name      = "issuance-${var.app_id}-sandpit-dot-com"

  metadata  = {
    pki-int-shared-role = "${var.app_id}-sandpit-dot-com"
  }
}

resource "vault_identity_entity_alias" "issuance" {
  namespace      = vault_namespace.this.path
  name           = "test-issuance"
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.issuance.id

  depends_on = [ 
  vault_identity_entity.issuance
  ]
}

resource "vault_identity_group_member_entity_ids" "issuance" {
  namespace         = "root"
  member_entity_ids = [vault_identity_entity.issuance.id]
  group_id          = var.issuance_identity_group_id
  exclusive         = false
}

// Add PKI role

resource "vault_pki_secret_backend_role" "this" {
   backend            = var.pki_int_path
   issuer_ref         = var.issuer_ref_int
   name               = "${var.app_id}-sandpit-dot-com"
   ttl                = 86400
   max_ttl            = 2592000
   allow_ip_sans      = true
   key_type           = "rsa"
   key_bits           = 4096
   allowed_domains    = [ "test.sandpit.com" ]
   allow_subdomains   = false
   allow_bare_domains = true
   organization       = [ "HashiCorp" ]
   country            = [ "AU" ]
}