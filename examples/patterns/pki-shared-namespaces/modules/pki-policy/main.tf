resource "vault_policy" "this" {
  name = "pki-shared"

  policy = <<EOT
path "pki*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}
EOT
}