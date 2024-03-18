module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.2"

  key_name           = var.deployment_id
  create_private_key = true
}

resource "local_sensitive_file" "key_pair_pem" {
  filename = "${path.root}/${module.key_pair.key_pair_name}.pem"
  file_permission = "400"
  content = module.key_pair.private_key_pem
}
