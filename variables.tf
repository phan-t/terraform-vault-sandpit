// generic variables

variable "deployment_name" {
  description = "deployment name to prefix resources"
  type        = string
  default     = "sandpit"
}

// amazon web services (aws) variables

variable "aws_region" {
  description = "aws region"
  type        = string
  default     = ""
}

variable "aws_route53_sandbox_prefix" {
  description = "aws route53 sandbox account prefix"
  type        = string
}

variable "aws_common_tags" {
  description = "map of common tags for taggable aws resources"
  type        = map(string)
  default     = {}
}

variable "aws_secretsmanager_secrets" {
  description = "map of vault secrets that will be stored in aws secrets manager."
  type = object({
    vault = optional(object({
      license = optional(object({
        name        = optional(string, "vault-license")
        description = optional(string, "vault license")
        data        = optional(string, null)
        path        = optional(string, null)
      }), {})
    }), {})
    ca_certificate_bundle = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "ca certificate")
      data        = optional(string, null)
    }), {})
    cert_pem_secret = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "pem-encoded serever certificate")
      data        = optional(string, null)
    }), {})
    cert_pem_private_key_secret = optional(object({
      name        = optional(string, null)
      path        = optional(string, null)
      description = optional(string, "pem-encoded server certificate private key")
      data        = optional(string, null)
    }), {})
  })
  default = {
    vault = {
      license = {
        name = "vault-license"
        path = "./vault-ent-license.hclic"
      }
    }
    ca_certificate_bundle = {
      name = "vault-ca-bundle"
      path = "./modules/prerequisites/tls/ca-cert.pem"
    }
    cert_pem_secret = {
      name = "vault-public-cert"
      path = "./modules/prerequisites/tls/server-cert.pem"
    }
    cert_pem_private_key_secret = {
      name = "vault-private-cert"
      path = "./modules/prerequisites/tls/server-key.pem"
    }
  }
}

variable "aws_iam_resources" {
  description = "list of objects referenced in an instance iam policy"
  type = object({
    bucket_arns             = optional(list(string), [])
    kms_key_arns            = optional(list(string), [])
    secret_manager_arns     = optional(list(string), [])
    log_group_arn           = optional(string, "")
    log_forwarding_enabled  = optional(bool, true)
    role_name               = optional(string, "vault-role")
    policy_name             = optional(string, "vault-policy")
    ssm_enable              = optional(bool, false)
    cloud_auto_join_enabled = optional(bool, true)
  })
  default = {
    ssm_enable             = true
    log_forwarding_enabled = true
  }
}

variable "aws_s3_buckets" {
  description = "map of s3 bucket configuration used by the installers"
  type = object({
    snapshot = optional(object({
      create                              = optional(bool, true)
      bucket_name                         = optional(string, "vault-snapshot-bucket")
      description                         = optional(string, "Storage location for Vault snapshots that will be exported")
      versioning                          = optional(bool, true)
      force_destroy                       = optional(bool, false)
      replication                         = optional(bool)
      replication_destination_bucket_arn  = optional(string)
      replication_destination_kms_key_arn = optional(string)
      replication_destination_region      = optional(string)
      encrypt                             = optional(bool, true)
      bucket_key_enabled                  = optional(bool, true)
      kms_key_arn                         = optional(string)
      sse_s3_managed_key                  = optional(bool, false)
      is_secondary_region                 = optional(bool, false)
    }), {})
  })
  default = {
    snapshot = {
    bucket_name   = "vault-westeros-snapshots"
    force_destroy = true
    }
  }
}

variable "aws_lb_sg_rules" {
  description = "map of various load balancer security group rules"
  type = object({
    vault_cluster_ingress = optional(object({
      type        = optional(string, "ingress")
      create      = optional(bool, false)
      from_port   = optional(string, "8201")
      to_port     = optional(string, "8201")
      protocol    = optional(string, "tcp")
      cidr_blocks = optional(list(string), [])
      description = optional(string, "Allow 8201 traffic inbound for Vault")
    }))
    vault_api_ingress = optional(object({
      type        = optional(string, "ingress")
      create      = optional(bool, true)
      from_port   = optional(string, "8200")
      to_port     = optional(string, "8200")
      protocol    = optional(string, "tcp")
      cidr_blocks = optional(list(string), [])
      description = optional(string, "Allow 8200 traffic inbound for Vault")
    }))
    egress = optional(object({
      type        = optional(string, "egress")
      create      = optional(bool, true)
      from_port   = optional(string, "0")
      to_port     = optional(string, "0")
      protocol    = optional(string, "-1")
      cidr_blocks = optional(list(string), ["0.0.0.0/0"])
      description = optional(string, "Allow traffic outbound")
    }))
  })
  default = {
    vault_api_ingress = {
      cidr_blocks = ["0.0.0.0/0"] // allow external traffic to the vault api/ui
    }
    egress            = {}
  }
}

variable "aws_route53_failover_record" {
  description = "if set, creates a route53 failover record"
  type = object({
    create              = optional(bool, true)
    set_id              = optional(string, "fso1")
    lb_failover_primary = optional(bool, true)
    record_name         = optional(string)
  })
  default = {
    create      = true
    record_name = "vault"
    set_id      = "fso1"
  }
}

// hashicorp self-managed vault variables

variable "vault_ent_license" {
  description = "vault enterprise license"
  type        = string
  default     = ""
}

variable "vault_version" {
  description = "vault version"
  type        = string
  default     = "1.15.6+ent"
}

