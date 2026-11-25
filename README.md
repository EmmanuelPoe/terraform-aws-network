# Terraform AWS Network

Terraform for an AWS VPC with public and private subnets across availability zones, an internet gateway, and optional NAT gateways (one per AZ for high availability, or a single shared one to save cost).

## What it builds

```
                         Internet
                            │
                    ┌───────▼────────┐
                    │ Internet GW    │
                    └───────┬────────┘
     ┌──────────────────────┼──────────────────────┐
     │ VPC 10.0.0.0/16      │                      │
     │  ┌─────────────┐ ┌───▼─────────┐ ┌─────────────┐
     │  │ public  AZ-a│ │ public  AZ-b│ │ public  AZ-c│   route 0.0.0.0/0 → IGW
     │  │   NAT GW    │ │   NAT GW    │ │   NAT GW    │
     │  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
     │  ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐
     │  │ private AZ-a│ │ private AZ-b│ │ private AZ-c│   route 0.0.0.0/0 → NAT in same AZ
     │  └─────────────┘ └─────────────┘ └─────────────┘
     └─────────────────────────────────────────────────┘
```

| Resource | Count |
|---|---|
| VPC (DNS support and hostnames on) | 1 |
| Public subnets (auto-assign public IP) | one per `public_subnets` entry |
| Private subnets | one per `private_subnets` entry |
| Internet gateway + public route table | 1 |
| Elastic IPs + NAT gateways | per AZ, 1 (`single_nat_gateway = true`), or 0 (`enable_nat_gateway = false`) |
| Private route tables | one per NAT gateway (1 when NAT is disabled, with no internet route) |

## Layout

```
main.tf                    provider + module "vpc"
variables.tf               root inputs
outputs.tf                 vpc_id, vpc_cidr, public/private subnet IDs, NAT gateway IDs
environments/prod.tfvars   production values (10.0.0.0/16, 3 AZs, NAT per AZ)
modules/vpc/               the VPC module (main.tf, variables.tf, outputs.tf)
```

## Usage

```bash
terraform init
terraform plan  -var-file=environments/prod.tfvars
terraform apply -var-file=environments/prod.tfvars
```

Or call the module directly:

```hcl
module "vpc" {
  source = "./modules/vpc"

  name            = "prod"
  cidr            = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false # one NAT gateway per AZ
}
```

### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | string | — | name prefix for all resources |
| `region` | string | `us-east-1` | AWS region (root module only) |
| `vpc_cidr` / `cidr` | string | — | VPC CIDR (root / module name) |
| `azs` | list(string) | — | availability zones |
| `public_subnets` | list(string) | — (`[]` in module) | public subnet CIDRs |
| `private_subnets` | list(string) | — (`[]` in module) | private subnet CIDRs |
| `enable_nat_gateway` | bool | `true` | create NAT gateways |
| `single_nat_gateway` | bool | `false` | share one NAT gateway |
| `tags` | map(string) | `{}` | tags for every resource |

Per-AZ NAT needs at least one public subnet per AZ; the module checks this at plan time.

### Outputs

`vpc_id`, `vpc_cidr`, `public_subnet_ids`, `private_subnet_ids`, `nat_gateway_ids`.

## Cost note

NAT gateways and their Elastic IPs are billed hourly plus data processing. For dev environments use `single_nat_gateway = true` or `enable_nat_gateway = false`.

## Roadmap

Not implemented yet: transit gateway, reusable security groups, VPC endpoints (S3, ECR, SSM), AWS Network Firewall, isolated/database subnet tier, and a remote state backend.

## Requirements

- Terraform >= 1.5, AWS provider >= 5.0
- AWS credentials from the environment (profile, SSO or role)

CI (`.github/workflows/terraform.yml`) runs `terraform fmt -check`, `init -backend=false` and `validate` on every pull request.

Agent and contributor docs: [CLAUDE.md](CLAUDE.md) and [docs/](docs/).
