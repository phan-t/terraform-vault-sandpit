resource "vault_policy" "issuance" {
  name = "pki-int-shared-tenant-issuance"

  policy = <<EOT
path "pki-int/issue/{{identity.entity.metadata.pki-int-shared-role}}" {
  capabilities = [ "create", "read", "update" ]
}

path "pki-int/roles/{{identity.entity.metadata.pki-int-shared-role}}" {
  capabilities = [ "read"]
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

resource "vault_policy" "config" {
  name = "pki-int-shared-tenant-config"

  policy = <<EOT
path "pki-int/roles/{{identity.entity.metadata.pki-int-shared-role}}" {
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

resource "vault_identity_group" "issuance" {
  namespace = "root"
  name      = "pki-int-shared-tenant-issuance"
  policies  = [ "pki-int-shared-tenant-issuance" ]
  type      = "internal"
} 