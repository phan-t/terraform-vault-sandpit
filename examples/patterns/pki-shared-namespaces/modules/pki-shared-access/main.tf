resource "vault_policy" "pki-shared" {
  name = "pki-shared"

  policy = <<EOT
path "pki*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}
EOT
}

resource "vault_identity_group" "pki-shared" {
   namespace = "root"
   name      = "pki-shared"
   policies  = ["pki-shared"]
   type      = "internal"
}