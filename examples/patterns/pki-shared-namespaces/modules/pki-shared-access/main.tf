resource "vault_policy" "issuance" {
  name = "pki-int-shared-tenant-issuance"

  policy = <<EOT
path "pki-int/issue/{{identity.entity.name}}" {
  capabilities = [ "create", "read", "update" ]
}
EOT
}

resource "vault_policy" "config" {
  name = "pki-int-shared-tenant-config"

  policy = <<EOT
path "pki-int/roles/{{identity.entity.name}}" {
  capabilities = [ "read", "update" ]
  allowed_parameters = {
    "*" = []
    "allowed_domains" = [ "test.sandpit.com" ]
  }
  denied_parameters = {
    "ou" = []
    "organization" = []
  }
}
EOT
}

resource "vault_identity_group" "config" {
  namespace = "root"
  name      = "pki-int-shared-tenant-config"
  policies  = [ "pki-int-shared-tenant-config" ]
  type      = "internal"
} 