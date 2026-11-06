# Account ids come from the landing-zone outputs; placeholders here keep the
# root plannable offline. Real values are supplied at apply time.

variable "ct_management_account_id" {
  type    = string
  default = "000000000000"
}

variable "log_archive_account_id" {
  type    = string
  default = "000000000000"
}

variable "audit_account_id" {
  type    = string
  default = "000000000000"
}

variable "aft_management_account_id" {
  type    = string
  default = "000000000000"
}

variable "ct_home_region" {
  type    = string
  default = "eu-west-1"
}

variable "tf_backend_secondary_region" {
  type    = string
  default = "eu-central-1"
}

variable "account_request_repo_name" {
  type    = string
  default = "acme/phoenix-aws-org"
}

variable "global_customizations_repo_name" {
  type    = string
  default = "acme/phoenix-aws-org"
}

variable "account_customizations_repo_name" {
  type    = string
  default = "acme/phoenix-aws-org"
}

variable "account_provisioning_customizations_repo_name" {
  type    = string
  default = "acme/phoenix-aws-org"
}
