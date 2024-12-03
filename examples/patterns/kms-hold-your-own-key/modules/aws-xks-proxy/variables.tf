variable "deployment_id" {
  description = "deployment id"
  type        = string
}

variable "region" {
  description = "aws region"
  type        = string
}

variable "route53_sandbox_prefix" {
  description = "aws route53 sandbox account prefix"
  type        = string
}

variable "vault_address" {
  type = string
}