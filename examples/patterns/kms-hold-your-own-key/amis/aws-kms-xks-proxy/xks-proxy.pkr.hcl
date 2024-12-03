packer {
  required_plugins {
    amazon = {
      version = "~> 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "vault_pkcs11_provider_version" {
  type    = string
  default = "0.2.0"
}

variable "vault_pkcs11_provider_download_url" {
  type    = string
  default = "https://releases.hashicorp.com/vault-pkcs11-provider"
}

data "amazon-ami" "ubuntu20" {
  filters = {
    architecture                       = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name                               = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    root-device-type                   = "ebs"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "${var.aws_region}"
}

source "amazon-ebs" "ubuntu20-ami" {
  ami_description             = "An Ubuntu 20.04 AMI that is running AWS xks-proxy on Docker."
  ami_name                    = "xks-proxy-ubuntu-${formatdate("YYYYMMDDhhmm", timestamp())}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  region                      = "${var.aws_region}"
  source_ami                  = "${data.amazon-ami.ubuntu20.id}"
  ssh_username                = "ubuntu"
  tags = {
    application     = "xks-proxy"
    owner           = "tphan@hashicorp.com"
    packer_source   = "https://github.com/phan-t/terraform-vault-sandpit/blob/master/examples/patterns/kms-hold-your-own-key/amis/aws-kms-xks-proxy/xks-proxy.pkr.hcl"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu20-ami"]

  // install dependencies
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common unzip",
      "sudo apt update",
      "sudo apt install -y make rustc cargo rpm alien"
    ]
  }

  // install docker
  provisioner "shell" {
    inline = [
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce",
      "sudo usermod -aG docker ubuntu",
    ]
  }

  // download and unzip vault_pkcs11_provider
  provisioner "shell" {
    inline = [
      "curl -o /var/tmp/vault-pkcs11-provider_${var.vault_pkcs11_provider_version}_linux-el9_amd64.zip ${var.vault_pkcs11_provider_download_url}/${var.vault_pkcs11_provider_version}/vault-pkcs11-provider_${var.vault_pkcs11_provider_version}_linux-el9_amd64.zip --location --silent --fail --show-error",
      "unzip -d /var/tmp /var/tmp/vault-pkcs11-provider_${var.vault_pkcs11_provider_version}_linux-el9_amd64.zip",
      "sudo chmod +x /var/tmp/libvault-pkcs11.so"
    ]
  }
}