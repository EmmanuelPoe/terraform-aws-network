# Testing

There are no automated tests or CI. Validate every change locally with the steps below, in order. None of them create AWS resources except `apply`.

```bash
terraform fmt -check -recursive      # formatting
terraform init -backend=false        # downloads the AWS provider; no credentials needed
terraform validate                   # syntax and type checks
terraform plan -var-file=environments/prod.tfvars   # needs AWS credentials (read-only calls)
```

As committed, `validate` fails because of `;` separators in four files (see CLAUDE.md). Fix those first.

## What to check in a plan

- Resource counts match the NAT mode table in [architecture.md](architecture.md): with `prod.tfvars` expect 1 VPC, 3 public + 3 private subnets, 1 IGW, 3 EIPs, 3 NAT gateways, 1 public + 3 private route tables, 6 associations.
- Toggle `-var enable_nat_gateway=false` and `-var single_nat_gateway=true` and confirm counts change as documented.
- Nothing is destroyed unexpectedly (`-/+` or `-` lines).

## Optional tooling

- `tflint` for provider-aware linting.
- `checkov -d .` or `tfsec .` for security misconfigurations.
- `terraform test` (Terraform >= 1.6) with a `tests/*.tftest.hcl` file using `command = plan` to assert resource counts per NAT mode without creating anything. If you add tests, document them here.
