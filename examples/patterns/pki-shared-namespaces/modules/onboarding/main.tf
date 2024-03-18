resource "vault_namespace" "this" {  
  path = var.app_id
}

resource "vault_auth_backend" "userpass" {
  namespace  = vault_namespace.this.path
  path       = "userpass"
  type       = "userpass"
}

resource "vault_generic_endpoint" "test-user" {
  namespace            = vault_namespace.this.path
  path                 = "auth/userpass/users/test-user"
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

resource "vault_identity_entity" "this" {
  namespace = vault_namespace.this.path
  name      = "test"
}

resource "vault_identity_entity_alias" "this" {
  namespace      = vault_namespace.this.path
  name           = "test-user"
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.this.id

  depends_on = [ 
  vault_identity_entity.this
  ]
}

resource "vault_identity_group_member_entity_ids" "this" {
  namespace         = "root"
  member_entity_ids = [vault_identity_entity.this.id]
  group_id          = var.pki_shared_identity_group_id
  exclusive         = false
}