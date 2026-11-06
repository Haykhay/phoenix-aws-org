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

variable "core_account_emails" {
  description = "Unique root emails for the core accounts."
  type = object({
    log_archive    = string
    audit          = string
    aft_management = string
  })
  default = {
    log_archive    = "aws+log-archive@example.com"
    audit          = "aws+audit@example.com"
    aft_management = "aws+aft@example.com"
  }
}

variable "governed_regions" {
  description = "Regions Control Tower governs."
  type        = list(string)
  default     = ["eu-west-1"]
}

variable "security_ou_name" {
  type    = string
  default = "Security"
}

variable "sandbox_ou_name" {
  type    = string
  default = "Sandbox"
}

variable "landing_zone_version" {
  type    = string
  default = "3.3"
}
