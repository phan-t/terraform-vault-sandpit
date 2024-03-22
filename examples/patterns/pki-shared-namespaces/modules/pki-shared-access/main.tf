resource "vault_policy" "pki-int-shared" {
  name = "pki-int-shared"

  policy = <<EOT
path "pki-int/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}
EOT
}

resource "vault_identity_group" "pki-int-shared" {
   namespace = "root"
   name      = "pki-int-shared"
   policies  = ["pki-int-shared"]
   type      = "internal"
}