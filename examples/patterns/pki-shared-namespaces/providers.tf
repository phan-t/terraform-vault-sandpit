terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "~> 3.25.0"
    }
  }
}

provider "vault" {
  address         = data.terraform_remote_state.tcm.outputs.vault_public_fqdn
  token           = var.vault_root_token
  skip_tls_verify = true
}