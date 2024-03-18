# Create namespaces
resource "vault_namespace" "us-west-org" {
   path = "us-west-org"
}

resource "vault_namespace" "us-east-org" {
   path = "us-east-org"
}

# Create 'customer-info-read-only' policy 
resource "vault_policy" "customer-info-read-only" {
   name       = "customer-info-read-only"
   namespace  = vault_namespace.us-west-org.path
   policy     = <<EOF
path "kv-customer-info/data/*" {
   capabilities = ["read"]
}
EOF
}

# Create 'marketing-read-only' policy
resource "vault_policy" "marketing-read-only" {
   name       = "marketing-read-only"
   namespace  = vault_namespace.us-east-org.path
   policy = <<EOF
path "kv-marketing/data/campaign" {
   capabilities = ["read"]
}
EOF
}

# Mount a new KV v2 secrets engine at kv-customer-info/ in the us-west-org namespace
resource "vault_mount" "kv-customer-info" {
   depends_on  = [vault_namespace.us-west-org]
   namespace   = vault_namespace.us-west-org.path
   path        = "kv-customer-info"
   type        = "kv-v2"
}

# Create test data at kv-customer-info/customer-001
resource "vault_kv_secret_v2" "customer" {
   depends_on  = [vault_mount.kv-customer-info]
   namespace   = vault_namespace.us-west-org.path
   mount                      = vault_mount.kv-customer-info.path
   name                       = "customer-001"
   delete_all_versions        = true
   data_json                  = jsonencode(
   {
      name          = "Example LLC",
      contact_email = "admin@example.com"
   }
   )
}

# Mount a new KV v2 secrets engine at kv-marketing/ in the us-east-org namespace
resource "vault_mount" "kv-marketing" {
   depends_on  = [vault_namespace.us-east-org]
   namespace   = vault_namespace.us-east-org.path
   path        = "kv-marketing"
   type        = "kv-v2"
}

# Create some test data at kv-marketing/campaign
resource "vault_kv_secret_v2" "campaign" {
   depends_on  = [vault_mount.kv-marketing]
   namespace   = vault_namespace.us-east-org.path
   mount                      = vault_mount.kv-marketing.path
   name                       = "campaign"
   delete_all_versions        = true
   data_json                  = jsonencode(
   {
      start_date = "March 1, 2023", 
      end_date   = "March 31, 2023", 
      prise      = "Certification, voucher", 
      quantity   = "100"
   }
   )
}

#------------------------------------------------------------
# Enable userpass in the us-west-org namespace
#------------------------------------------------------------
resource "vault_auth_backend" "userpass" {
   type = "userpass"
   namespace  = vault_namespace.us-west-org.path
   path = "userpass"
}

# Create a user named, "tam-user" 
resource "vault_generic_endpoint" "tam-user" {
   depends_on           = [vault_auth_backend.userpass]
   namespace            = vault_namespace.us-west-org.path
   path                 = "auth/userpass/users/tam-user"
   ignore_absent_fields = true

   data_json = <<EOT
{
"policies": ["customer-info-read-only"],
"password": "my-long-password"
}
EOT
}

#------------------------------------------------------------
# Create an entity, 'TAM' in "us-west-org/" namespace
#------------------------------------------------------------
resource "vault_identity_entity" "tam" {
   namespace   = vault_namespace.us-west-org.path
   name        = "TAM"
}

resource "vault_identity_entity_alias" "tam" {
   depends_on      = [vault_identity_entity.tam]
   namespace       = vault_namespace.us-west-org.path
   name            = "tam-user"
   mount_accessor  = vault_auth_backend.userpass.accessor
   canonical_id    = vault_identity_entity.tam.id
}

#------------------------------------------------------------
# Create Identity Groups in "us-east-org/" namespace
#------------------------------------------------------------
resource "vault_identity_group" "campaign-admin" {
   namespace  = vault_namespace.us-east-org.path
   name       = "campaign-admin"
   policies   = ["marketing-read-only"]
   type       = "internal"
}

resource "vault_identity_group_member_entity_ids" "campaign-admin" {
   namespace  = vault_namespace.us-east-org.path
   member_entity_ids = [vault_identity_entity.tam.id]
   group_id = vault_identity_group.campaign-admin.id
   exclusive = false
}
