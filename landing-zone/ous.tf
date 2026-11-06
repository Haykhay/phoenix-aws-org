# Control Tower creates and registers these OUs (first-time setup, see README).
# Terraform NEVER creates OUs here — it only resolves each declared path to its
# live managed-OU id, for SCP attachment and AFT account placement.

locals {
  ous = yamldecode(file("${path.module}/ous.yaml")).organizational_units

  # Every declared OU path (roots and children), computed purely from the YAML.
  declared_ou_paths = concat(
    keys(local.ous),
    flatten([for parent, cfg in local.ous : [for c in try(cfg.children, []) : "${parent}/${c}"]]),
  )
}

data "aws_organizations_organization" "this" {}

locals {
  # try() keeps the config evaluable under mock providers (offline tests).
  root_id = try(data.aws_organizations_organization.this.roots[0].id, "r-root")
}

# Root-level managed OUs.
data "aws_organizations_organizational_units" "root" {
  parent_id = local.root_id
}

locals {
  root_ou_ids = { for ou in data.aws_organizations_organizational_units.root.children : ou.name => ou.id }
}

# Second-level OUs, only under roots that declare children.
data "aws_organizations_organizational_units" "child" {
  for_each  = { for parent, cfg in local.ous : parent => cfg if length(try(cfg.children, [])) > 0 }
  parent_id = lookup(local.root_ou_ids, each.key, local.root_id)
}

locals {
  child_ou_ids = merge({}, [
    for parent, d in data.aws_organizations_organizational_units.child :
    { for ou in d.children : "${parent}/${ou.name}" => ou.id }
  ]...)

  ou_ids = merge(local.root_ou_ids, local.child_ou_ids)
}
