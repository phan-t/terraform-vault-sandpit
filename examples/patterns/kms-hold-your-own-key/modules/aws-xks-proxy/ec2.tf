locals {
  key_pair_private_key = file("../../../${var.deployment_id}.pem")
}

resource "local_file" "xks-proxy-config" {
  content = templatefile("${path.root}/templates/settings_vault.toml.tpl", {
    aws_region = var.region
    path_libvault_pkcs11 = "/usr/local/lib/xks-vault-configs/libvault-pkcs11.so"
    })
  filename = "${path.root}/configs/settings_vault.toml"
}

resource "local_file" "vault-pkcs11-config" {
  content = templatefile("${path.root}/templates/vault-pkcs11.hcl.tpl", {
    vault_address = trimsuffix(trimprefix(var.vault_address, "https://"), ":8200/")
    path_tls_cert = "/usr/local/lib/xks-vault-configs/kmip_credentials_cert.pem"
    path_ca_cert = "/usr/local/lib/xks-vault-configs/kmip_credentials_ca.pem"
    kmip_scope = "hyok"
    })
  filename = "${path.root}/configs/vault-pkcs11.hcl"
}

data "archive_file" "config-bundle" {
  type        = "zip"
  source_dir = "${path.root}/configs"
  output_path = "${path.root}/config-bundle/xks-vault-config-bundle.zip.tmp"

  depends_on = [
    local_file.xks-proxy-config,
    local_file.vault-pkcs11-config
  ]
}

data "aws_ami" "xks-proxy" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["xks-proxy-ubuntu-*"]
  }

  filter {
    name   = "tag:application"
    values = ["xks-proxy"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

resource "aws_instance" "xks-proxy" {
  ami             = data.aws_ami.xks-proxy.id
  instance_type   = "t2.small"
  key_name        = var.deployment_id
  subnet_id       = element(data.aws_subnets.public.ids, 1)
  security_groups = [module.sg-xks-proxy.security_group_id]

  lifecycle {
    ignore_changes = all
  }
  
  tags = {
    Name  = "${var.deployment_id}-xks-proxy"
  }

  connection {
    host          = aws_instance.xks-proxy.public_dns
    user          = "ubuntu"
    agent         = false
    private_key   = local.key_pair_private_key
  }

  provisioner "file" {
    source      = data.archive_file.config-bundle.output_path
    destination = "/var/tmp/xks-vault-config-bundle.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /xks-vault-configs",
      "sudo cp /var/tmp/libvault-pkcs11.so /xks-vault-configs",
      "sudo unzip -d /xks-vault-configs /var/tmp/xks-vault-config-bundle.zip",
      "docker pull phantony/aws-xks-proxy:0.2",
      "docker run --rm --name xks-proxy -d -p 0.0.0.0:8000:8000 --mount type=bind,source=/xks-vault-configs,target=/usr/local/lib/xks-vault-configs -e XKS_PROXY_SETTINGS_TOML=/usr/local/lib/xks-vault-configs/settings_vault.toml -e VAULT_KMIP_CONFIG=/usr/local/lib/xks-vault-configs/vault-pkcs11.hcl phantony/aws-xks-proxy:0.2"
    ]
  }
}