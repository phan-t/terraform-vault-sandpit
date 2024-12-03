terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "~> 3.25.0"
    }
  }
}

provider "aws" {
  region = data.terraform_remote_state.tcm.outputs.aws_region
}

provider "vault" {
  address         = data.terraform_remote_state.tcm.outputs.vault_public_fqdn
  token           = var.vault_root_token
  skip_tls_verify = true
}