variable "name"   { type = string }
variable "region" { type = string; default = "us-east-1" }
variable "vpc_cidr"        { type = string }
variable "azs"             { type = list(string) }
variable "public_subnets"  { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "enable_nat_gateway" { type = bool; default = true }
variable "single_nat_gateway" { type = bool; default = false }
variable "tags"            { type = map(string); default = {} }
