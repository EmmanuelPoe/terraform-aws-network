# Architecture

## Root module

`main.tf` configures the AWS provider (`region = var.region`) and calls `module "vpc"` with every root variable passed straight through. Root `variables.tf` mirrors the module's inputs; `environments/prod.tfvars` supplies values.

## `modules/vpc`

| Resource | Count | Notes |
|---|---|---|
| `aws_vpc.this` | 1 | DNS hostnames and support enabled |
| `aws_subnet.public` | `length(public_subnets)` | `map_public_ip_on_launch = true`; AZ = `azs[i % length(azs)]`; tag `Tier = public` |
| `aws_subnet.private` | `length(private_subnets)` | same AZ rotation; tag `Tier = private` |
| `aws_internet_gateway.this` | 1 | |
| `aws_eip.nat` / `aws_nat_gateway.this` | 0, 1 or `length(azs)` | see NAT modes below; NAT *i* sits in public subnet *i* |
| `aws_route_table.public` | 1 | `0.0.0.0/0 → IGW`, associated with every public subnet |
| `aws_route_table.private` | 1 or `length(azs)` | `0.0.0.0/0 → NAT` when NAT is enabled; no default route otherwise |

### NAT modes

| `enable_nat_gateway` | `single_nat_gateway` | NAT gateways | Private route tables |
|---|---|---|---|
| `false` | any | 0 | 1 (no internet route) |
| `true` | `true` | 1 | 1, all private subnets share it |
| `true` | `false` (prod default) | one per AZ | one per AZ; private subnet *i* uses table `i % count` |

Per-AZ NAT requires at least as many public subnets as AZs, because NAT *i* is placed in `aws_subnet.public[i]` (enforced by a precondition).

### Inputs and outputs

Inputs: `name`, `cidr`, `azs`, `public_subnets` (default `[]`), `private_subnets` (default `[]`), `enable_nat_gateway` (default `true`), `single_nat_gateway` (default `false`), `tags` (default `{}`).

Outputs: `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `vpc_cidr`, `nat_gateway_ids`, all re-exported by root `outputs.tf`.

A `lifecycle.precondition` on `aws_nat_gateway.this` fails the plan when per-AZ NAT is requested with fewer public subnets than AZs.

## Production values (`environments/prod.tfvars`)

VPC `10.0.0.0/16` in `us-east-1a/b/c`; public `10.0.101-103.0/24`; private `10.0.1-3.0/24`; one NAT gateway per AZ.

## Not implemented (README roadmap)

Transit gateway, security groups, VPC endpoints, network firewall, an isolated/DB subnet tier, and a remote state backend. CI only validates; it never plans or applies.

## Adding a module

Create `modules/<name>/{main,variables,outputs}.tf`, add a `module "<name>"` block in root `main.tf`, add matching root variables, and set them in `environments/*.tfvars`. Wire dependencies through module outputs (e.g. `module.vpc.vpc_id`), not hard-coded IDs.
