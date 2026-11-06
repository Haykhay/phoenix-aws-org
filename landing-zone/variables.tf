variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "assume_role_arn" {
  type    = string
  default = "arn:aws:iam::000000000000:role/placeholder"
}

variable "scp_target_ou_keys" {
  description = "OU paths the baseline SCP attaches to. Defaults to every declared OU."
  type        = list(string)
  default     = null
}
