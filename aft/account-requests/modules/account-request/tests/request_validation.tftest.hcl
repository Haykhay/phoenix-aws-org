run "accepts_valid_request" {
  command = plan

  variables {
    group        = "research"
    email        = "research@example.com"
    ou           = "sandbox"
    organisation = "acme"
    base_domain  = "example.com"
    apps_repo    = "git@github.com:acme/phoenix-apps.git"
  }
}

run "rejects_unknown_ou" {
  command = plan

  variables {
    group        = "research"
    email        = "research@example.com"
    ou           = "not-an-ou"
    organisation = "acme"
    base_domain  = "example.com"
    apps_repo    = "git@github.com:acme/phoenix-apps.git"
  }

  expect_failures = [terraform_data.validate]
}

run "rejects_bad_email" {
  command = plan

  variables {
    group        = "research"
    email        = "nope"
    ou           = "sandbox"
    organisation = "acme"
    base_domain  = "example.com"
    apps_repo    = "git@github.com:acme/phoenix-apps.git"
  }

  expect_failures = [var.email]
}
