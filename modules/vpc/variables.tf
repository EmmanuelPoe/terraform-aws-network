variable "name" {
  description = "Name prefix for every resource."
  type        = string
}

variable "cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "Availability zones to spread subnets across."
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDRs, assigned to AZs in order."
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "Private subnet CIDRs, assigned to AZs in order."
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway(s) for private subnet egress."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
