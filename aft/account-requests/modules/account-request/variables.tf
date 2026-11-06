variable "group" {
  type        = string
  description = "Group slug; also the registry partition key."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.group))
    error_message = "group must be lowercase alphanumeric/hyphen, 2-31 chars."
  }
}

variable "email" {
  type        = string
  description = "Root email for the vended account."
  validation {
    condition     = can(regex("^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$", var.email))
    error_message = "email must be a valid address."
  }
}

variable "ou" {
  type        = string
  description = "Target Control Tower-managed OU path (validated against landing-zone/ous.yaml)."
}

variable "organisation" {
  type        = string
  description = "Organisation slug."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.organisation))
    error_message = "organisation must be lowercase alphanumeric/hyphen."
  }
}

variable "base_domain" {
  type        = string
  description = "Base DNS domain for the group."
  validation {
    condition     = can(regex("^([a-z0-9-]+\\.)+[a-z]{2,}$", var.base_domain))
    error_message = "base_domain must be a valid domain name."
  }
}

variable "apps_repo" {
  type        = string
  description = "GitOps repository the group's clusters bootstrap from."
  validation {
    condition     = can(regex("^(git@|https://)", var.apps_repo))
    error_message = "apps_repo must be a git ssh or https URL."
  }
}
