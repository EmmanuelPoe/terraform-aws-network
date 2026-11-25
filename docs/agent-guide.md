# Agent guide

## Before you start

Run `terraform init -backend=false && terraform validate` to confirm a clean baseline.

## Recipes

**Add an input to the VPC module**
1. `modules/vpc/variables.tf`: add the variable with `type`, `description` and a safe default.
2. Use it in `modules/vpc/main.tf`.
3. Root `variables.tf`: add the same variable; root `main.tf`: pass it to `module "vpc"`.
4. `environments/prod.tfvars`: set it if prod needs a non-default value.
5. `fmt`, `validate`, `plan`.

**Add an output callers can use**: add it to `modules/vpc/outputs.tf` (with a `description`), then re-export it in root `outputs.tf` and list it in the README.

**Add a new environment**: copy `environments/prod.tfvars` to `environments/<env>.tfvars`, change `name`, CIDRs and tags; keep CIDRs non-overlapping with other environments.

**Build one of the README's missing modules**: new folder under `modules/`, consume `module.vpc` outputs, add a variable to toggle it, and move it from the README roadmap to the documented layout.

## Pitfalls

- Per-AZ NAT indexes `aws_subnet.public[count.index]`; the precondition rejects fewer public subnets than AZs.
- Subnet AZs rotate with `count.index % length(azs)`; reordering the `azs` list moves subnets and forces replacement.
- Changing `count`-based lists (inserting a subnet in the middle) re-indexes and replaces resources. Append to the end, or migrate to `for_each` with stable keys.
- Never run `apply`/`destroy` without explicit user approval; state is local, so applies from two machines will diverge.

## Done means

`terraform fmt -check -recursive` and `terraform validate` pass, the plan matches expectations, and README/docs reflect the change.
