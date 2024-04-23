output "config_identity_group_id" {
  value = vault_identity_group.config.id
}

output "issuance_identity_group_id" {
  value = vault_identity_group.issuance.id
}