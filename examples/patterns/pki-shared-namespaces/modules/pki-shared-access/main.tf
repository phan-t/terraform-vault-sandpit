resource "vault_policy" "pki-int-shared" {
  name = "pki-int-shared"

  policy = <<EOT
path "pki-int/issue/{{identity.entity.name}}" {
  capabilities = [ "create", "read", "update" ]
}

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

resource "vault_identity_group" "pki-int-shared" {
  namespace = "root"
  name      = "pki-int-shared"
  policies  = [ "pki-int-shared" ]
  type      = "internal"
}