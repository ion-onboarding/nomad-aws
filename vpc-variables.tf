## VPC Variables
variable "vpc_cidr" {
  description = "Cidr block for the VPC.  Using a /16 or /20 Subnet Mask is recommended."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_instance_tenancy" {
  description = "Tenancy for instances launched into the VPC."
  type        = string
  default     = "default"
}

variable "vpc_tags" {
  description = "Additional tags to add to the VPC and its resources."
  type        = map(string)
  default     = {}
}

variable "vpc_public_subnet_count" {
  description = "The number of public subnets to create.  Cannot exceed the number of AZs in your selected region.  2 is more than enough."
  type        = number
  default     = 2
}

variable "vpc_private_subnet_count" {
  description = "The number of private subnets to create.  Cannot exceed the number of AZs in your selected region."
  type        = number
  default     = 2
}

## Allowed Traffic into the Bastion
variable "allowed_bastion_cidr_blocks" {
  description = "List of CIDR blocks allowed to access your Bastion.  Defaults to Everywhere."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_bastion_cidr_blocks_ipv6" {
  description = "List of CIDR blocks allowed to access your Bastion.  Defaults to none."
  type        = list(string)
  default     = []
}

## Allowed Traffic into the Consul Server
variable "allowed_traffic_cidr_blocks" {
  description = "List of CIDR blocks allowed to send requests to your consul server endpoint.  Defaults to EVERYWHERE."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_traffic_cidr_blocks_ipv6" {
  description = "List of IPv6 CIDR blocks allowed to send requests to your consul server endpoint.  Defaults to EVERYWHERE."
  type        = list(string)
  default     = ["::/0"]
}