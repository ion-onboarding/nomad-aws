## General Variables
variable "main_project_tag" {
  description = "Tag that will be attached to all resources."
  type        = string
  default     = "nomad"
}

variable "aws_default_region" {
  description = "The default region that all resources will be deployed into."
  type        = string
  default     = "eu-north-1"
}

#
# VPC
#

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

#
# EC2
#

## Nomad Variables
variable "nomad_instances_count" {
  description = "How many servers must come online"
  default     = 3
}

variable "nomad_region" {
  description = "Nomad Region name"
  default     = "global"
}

variable "nomad_datacenter" {
  description = "Nomad datacenter name"
  default     = "dc1"
}

variable "nomad_instance_type" {
  description = "EC2 instance type: t2.micro, t3.medium, etc"
  default     = "t3.medium"
}

## Consul Variables
variable "consul_instances_count" {
  description = "How many servers must come online. At this moment count cannot be changed"
  default     = 3
}

variable "consul_datacenter" {
  description = "Consul datacenter name"
  default     = "dc1"
}

variable "consul_instance_type" {
  description = "EC2 instance type: t2.micro, t3.medium, etc"
  default     = "t3.medium"
}

## Vault Variables
variable "vault_instances_count" {
  description = "How many servers must come online"
  default     = 3
}

variable "vault_instance_type" {
  description = "EC2 instance type: t2.micro, t3.medium, etc"
  default     = "t3.medium"
}

## Client Variables
variable "client_instance_type" {
  description = "EC2 instance type: t2.micro, t3.medium, etc"
  default     = "t3.medium"
}

variable "client_instances_count" {
  description = "How many servers must come online"
  default     = 5
}

## Bastion enable disable
variable "bastion_enable" {
  description = "Enable or Disable bastion: true or false"
  type        = bool
  default     = "false"
}