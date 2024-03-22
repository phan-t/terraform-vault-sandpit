data "terraform_remote_state" "tcm" {
  backend = "local"

  config = {
    path = "../../../terraform.tfstate"
  }
}

module "pki" {
  source = "./modules/pki"
}

module "pki-int-shared-access" {
  source = "./modules/pki-shared-access"
}

module "onboarding" {
  source = "./modules/onboarding"
  count = 10

  app_id                           = "${var.app_prefix}-${format("%04d", count.index + 1)}"
  pki_int_path                     = module.pki.pki_int_path
  issuer_ref_int                   = module.pki.issuer_ref_int
  pki_int_shared_identity_group_id = module.pki-int-shared-access.identity_group_id
}