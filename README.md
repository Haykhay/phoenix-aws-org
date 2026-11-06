# Phoenix AWS — organization (Layer 0)

Account vending for Phoenix. This layer turns a committed account request into an
**enrolled, Terraform-ready AWS account** whose ID the rest of the platform reads
from a registry. It sits beneath `infrastructure/` (Layer 2) and `k8s-installs/`
(Layer 3): its one job is to make an account *exist and be usable by Terraform*
before any other layer runs.

It is a **greenfield build**. The only thing assumed is an AWS account to serve
as the management (payer) account, and credentials to run Terraform in it — an
account cannot create its own organization from nothing. Everything else is
built here as code: AWS Organizations, the Control Tower landing zone (with its
Log Archive and Audit accounts), the OU tree, the guardrails, and the Account
Factory for Terraform (AFT) deployment.

The invariant the whole series depends on: every account has deploy roles with
**constant names** — `Terraform-Role` (apply/destroy from `main`) and
`Terraform-Plan-Role` (read-only, pull requests) — so the only variable a
consumer ever needs is the **account ID**.

| Folder | What |
|---|---|
| [`landing-zone/`](landing-zone/) | AWS Organizations, the Control Tower landing zone, the core accounts, the OU tree, and the baseline SCP |
| [`aft/aft-bootstrap/`](aft/aft-bootstrap/) | the AFT deployment (`aws-ia/control_tower_account_factory`) |
| [`aft/account-requests/`](aft/account-requests/) | one file per group account — Backstage commits here |
| [`aft/account-customizations/phoenix-baseline/`](aft/account-customizations/phoenix-baseline/) | the CloudFormation that makes each new account Terraform-ready |
| [`registry/`](registry/) | the DynamoDB account registry and the CI upsert |
| [`.github/workflows/org.yml`](.github/workflows/org.yml) | validate on PR; apply the org, AFT and registry on `main` |

## How a group account is created

1. **Request** — a privileged Backstage "new group" template (platform team only)
   commits one `aft/account-requests/<group>.tf`. It carries the group, email,
   target OU, and tags — **never** an account ID; Control Tower assigns that.
   Backstage calls no AWS API; it only writes config to Git.
2. **Provision** — merging to `main` triggers AFT, which asks Control Tower to
   vend the account **if it does not already exist**, enrols it into the target
   OU (so the guardrails attach), and runs the customizations.
3. **Baseline** — the `phoenix-baseline` CloudFormation customization creates, in
   the new account: `Terraform-Role`, `Terraform-Plan-Role`, a GitHub OIDC
   provider, and the state bucket `<org>-tfstate-<account_id>` (versioned,
   encrypted, public-access-blocked; S3-native state locking).
4. **Round-trip** — AFT emits the new account ID; a CI step upserts the
   **DynamoDB registry** (partition key `group`). Backstage reads the registry
   through a custom entity provider, so every later environment/workload request
   resolves `account_id` from it. The registry is the durable source of truth: a
   Backstage rebuild re-syncs from it.

Removing a request file never deletes an account — decommissioning a group is a
deliberate, manual Control Tower action.

## OU structure

De-branded, adopted from a production reference (no organisation name, no legacy
migration OUs):

```
root
├── sandbox                 # personal / sandbox group accounts
├── shared-services
├── infrastructure
│   ├── networking · identity · tooling · monitoring · security
└── workloads
    ├── nonprod
    └── production
```

The OU tree is created by Terraform under the Control Tower-governed org.
Control Tower's own foundational Security OU (Log Archive + Audit) comes from the
landing-zone manifest and is separate from this tree. A request's `ou` field must
name one of these paths.

The baseline SCP (adapted, de-branded, from the reference) denies org-wide:
leaving the organization, root-user activity, tampering with CloudTrail / Config
/ GuardDuty / Security Hub / Macie / Access Analyzer / Inspector / Detective /
Backup, removing S3 public-access blocks, and disabling EBS default encryption —
layered on top of Control Tower's own controls.

## Status

**Designed and verified offline; not yet applied to a real AWS account.** The
entire definition — Organizations, Control Tower, OUs, SCP, AFT, the baseline,
the registry, and the CI — lives in this repo and passes the offline checks
below. What offline verification cannot prove is reserved for the first apply:

- the Control Tower landing zone actually standing up (~30–60 min) and governing
  the OUs;
- AFT's pipelines deploying and sequencing an account end to end;
- GitHub OIDC assumption into the baseline roles.

Those are the Layer 0 equivalent of the series' "going live" step.

## Running the checks

Toolchain: `terraform` ≥ 1.15, `tflint`, `checkov`, `cfn-lint`, `cfn-guard`,
`actionlint`, `python3`. Confirm with `make tools`; prime tflint once with
`make init`.

```bash
make verify        # every offline check: terraform test, tflint, checkov,
                   # cfn-lint, cfn-guard, the registry unittest, actionlint
make verify-aft    # heavy: resolves the AFT module, then validate + tflint
```

`make verify` deliberately excludes `aft/aft-bootstrap`: it is a single call to
the large `aws-ia/control_tower_account_factory` module, too big for a meaningful
offline `terraform test`, so it is validate-level only via `make verify-aft`.

Design records and the architecture decision for this layer (Control Tower + AFT,
the DynamoDB registry, S3-native locking) are kept local under `docs/` and are
not tracked, per the series convention.
