# The OU tree, CREATED under the Control Tower-governed org (YAML-driven, the
# eeze reference's pattern). Control Tower's foundational Security OU comes from
# the landing-zone manifest and is not part of this tree.

locals {
  ous = yamldecode(file("${path.module}/ous.yaml")).organizational_units

  declared_ou_paths = concat(
    keys(local.ous),
    flatten([for parent, cfg in local.ous : [for c in try(cfg.children, []) : "${parent}/${c}"]]),
  )

  child_ous = flatten([
    for parent, cfg in local.ous : [
      for c in try(cfg.children, []) : { parent = parent, name = c }
    ]
  ])
}

resource "aws_organizations_organizational_unit" "root" {
  for_each = local.ous

  name      = each.key
  parent_id = local.org_root_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_organizational_unit" "child" {
  for_each = { for c in local.child_ous : "${c.parent}/${c.name}" => c }

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.root[each.value.parent].id

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  ou_ids = merge(
    { for k, v in aws_organizations_organizational_unit.root : k => v.id },
    { for k, v in aws_organizations_organizational_unit.child : k => v.id },
  )
}
