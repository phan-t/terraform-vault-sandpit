data "terraform_remote_state" "tcm" {
  backend = "local"

  config = {
    path = "../../../terraform.tfstate"
  }
}

module "kmip" {
  source = "./modules/kmip"

  deployment_id = data.terraform_remote_state.tcm.outputs.deployment_id
  aws_lb_arn = data.terraform_remote_state.tcm.outputs.aws_lb_arn
  vault_address = data.terraform_remote_state.tcm.outputs.vault_public_fqdn
  vault_token = var.vault_root_token
}

module "aws-xks-proxy" {
  source = "./modules/aws-xks-proxy"

  deployment_id = data.terraform_remote_state.tcm.outputs.deployment_id
  region = data.terraform_remote_state.tcm.outputs.aws_region
  route53_sandbox_prefix = var.aws_route53_sandbox_prefix
  vault_address = data.terraform_remote_state.tcm.outputs.vault_public_fqdn

  depends_on = [
    module.kmip
  ]
}