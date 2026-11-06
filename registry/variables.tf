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
