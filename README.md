# Terraform AWS Network Modules

Production-ready Terraform modules for building enterprise AWS network infrastructure. Implements AWS networking best practices for multi-account, multi-region environments.

## Modules

| Module | Description |
|--------|-------------|
| `vpc` | VPC with public/private/isolated subnets across AZs |
| `transit-gateway` | TGW with route tables and VPC attachments |
| `security-groups` | Reusable security group patterns |
| `vpc-endpoints` | S3, ECR, SSM and other VPC endpoints |
| `network-firewall` | AWS Network Firewall with stateful rules |

## Architecture

```
                    ┌─────────────────────────┐
                    │     Transit Gateway      │
                    └────────┬────────┬────────┘
                             │        │
              ┌──────────────┘        └──────────────┐
              │                                       │
    ┌─────────▼──────────┐               ┌────────────▼───────────┐
    │   Production VPC    │               │    Inspection VPC       │
    │  ┌───────────────┐  │               │  ┌──────────────────┐   │
    │  │ Public Subnet │  │               │  │  Network Firewall│   │
    │  ├───────────────┤  │               │  └──────────────────┘   │
    │  │Private Subnet │  │               └────────────────────────┘
    │  ├───────────────┤  │
    │  │  DB Subnet    │  │
    │  └───────────────┘  │
    └────────────────────┘
```

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  name             = "prod"
  cidr             = "10.0.0.0/16"
  azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false  # HA: one per AZ
}

module "transit_gateway" {
  source = "./modules/transit-gateway"

  name        = "core-tgw"
  vpc_ids     = [module.vpc.vpc_id]
  cidr_blocks = ["10.0.0.0/8"]
}
```

## Quick Start

```bash
terraform init
terraform plan -var-file=environments/prod.tfvars
terraform apply -var-file=environments/prod.tfvars
```

## Requirements

- Terraform >= 1.5
- AWS provider >= 5.0
- AWS credentials configured
