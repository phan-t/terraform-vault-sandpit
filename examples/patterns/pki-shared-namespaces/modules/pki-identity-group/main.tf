resource "vault_identity_group" "pki-shared" {
   namespace = "root"
   name      = "pki-shared"
   policies  = ["pki-shared"]
   type      = "internal"
}