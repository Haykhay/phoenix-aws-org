variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "assume_role_arn" {
  type    = string
  default = "arn:aws:iam::000000000000:role/placeholder"
}

variable "table_name" {
  type    = string
  default = "phoenix-account-registry"
}

variable "floci" {
  description = "Target a local Floci (endpoints + skip flags) instead of real AWS."
  type        = bool
  default     = false
}

variable "floci_endpoint" {
  type    = string
  default = "http://localhost:4566"
}
