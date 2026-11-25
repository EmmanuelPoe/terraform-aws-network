# CLAUDE.md

Guidance for AI agents working in this repository. Read this first, then the file in `docs/` that matches your task.

## What this is

Terraform for an AWS VPC: one root module (`main.tf`) that calls a single local module, `modules/vpc`, which creates the VPC, public/private subnets across AZs, an internet gateway, optional NAT gateways (one per AZ or a single shared one), and route tables.

Only `modules/vpc` exists. Transit gateway, security group, VPC endpoint and network firewall modules are on the README's roadmap, not in code; if asked to build one, create it under `modules/<name>/` following [docs/architecture.md](docs/architecture.md).

## Commands

```bash
terraform init
terraform fmt -recursive          # CI runs: terraform fmt -check -recursive
terraform validate
terraform plan  -var-file=environments/prod.tfvars
terraform apply -var-file=environments/prod.tfvars   # creates billable resources (NAT gateways, EIPs)
```

Requires Terraform >= 1.5 and AWS provider >= 5.0, with AWS credentials from the environment (`AWS_PROFILE` or SSO). There is no remote backend configured — state is local.

## Layout

```
main.tf                 root: provider + module "vpc"
variables.tf            root inputs (name, region, vpc_cidr, azs, subnets, NAT flags, tags)
outputs.tf              re-exports module outputs
.github/workflows/terraform.yml   fmt -check, init -backend=false, validate on PRs
environments/prod.tfvars  values for the prod VPC (10.0.0.0/16, 3 AZs)
modules/vpc/            the only module: main.tf, variables.tf, outputs.tf
```

## Rules for agents

- Never run `terraform apply` or `destroy` unless the user explicitly asks; `plan` is the safe default.
- Never commit state (`*.tfstate*`), `.terraform/`, or credentials — they are gitignored; keep it that way.
- Keep root variables and module variables in sync: a new module input needs a root variable, a pass-through in `main.tf`, and a value in `environments/*.tfvars`.
- Tag every resource with `merge(var.tags, { Name = ... })`, matching the existing pattern.
- When you change behavior, keep `README.md` (inputs/outputs tables, roadmap) accurate.

## Docs

- [docs/architecture.md](docs/architecture.md) — resources, NAT/route-table logic, module contract
- [docs/security.md](docs/security.md) — exposure, credentials, state
- [docs/testing.md](docs/testing.md) — how to validate changes without an AWS bill
- [docs/agent-guide.md](docs/agent-guide.md) — task recipes and pitfalls

There is no UI in this repository.
