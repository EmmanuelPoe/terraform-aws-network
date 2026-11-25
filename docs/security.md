# Security

This is a public repository. Treat everything committed as visible to the world.

## Credentials and state

- AWS credentials come only from the environment (profile, SSO or instance role). Never add `access_key`/`secret_key` to the provider block or to `*.tfvars`.
- State is local (no backend block) and contains resource IDs and attributes. `*.tfstate*` and `.terraform/` are gitignored; never commit them. If remote state is added, use an encrypted S3 bucket with a DynamoDB lock table and block public access.
- `environments/prod.tfvars` is committed on purpose and contains only CIDRs, AZs and tags. Keep secrets out of it; anything sensitive belongs in environment variables (`TF_VAR_*`) or a secrets manager.
- `.gitignore` also blocks `.env*`, private keys, `.aws/` and `credentials.json`.

## Network exposure created by this code

- Public subnets set `map_public_ip_on_launch = true`: anything launched there gets a public IP. Place workloads in private subnets unless they must be internet-facing.
- The public route table sends `0.0.0.0/0` to the internet gateway; private tables route `0.0.0.0/0` to NAT (egress only).
- No security groups, NACLs, VPC flow logs or VPC endpoints are created. If you add them: default-deny ingress, no `0.0.0.0/0` on admin ports (22, 3389, databases), and enable flow logs for any production VPC.

## Review checklist for changes

- No new `0.0.0.0/0` ingress rules.
- No hard-coded account IDs, ARNs with account numbers, or credentials.
- `terraform plan` reviewed before any apply; NAT gateways and EIPs are billable.
- `.terraform.lock.hcl` is currently gitignored; committing it would pin provider versions and is recommended.
