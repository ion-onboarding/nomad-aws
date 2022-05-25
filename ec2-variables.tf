#
# Nomad
#

variable "nomad_enterprise_enabled" {
  description = "true => install Enterprise, false => install OSS"
  type        = bool
  default     = "false"
}

variable "nomad_version" {
  description = "version to be used in format x.y.z, default is null string (meaning latest version)"
  default     = ""
}

variable "nomad_instances_count" {
  description = "How many servers must come online"
  default     = 1
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


#
# Consul
#

variable "consul_enterprise_enabled" {
  description = "true => install Enterprise, false => install OSS"
  type        = bool
  default     = "false"
}

variable "consul_version" {
  description = "version to be used in format x.y.z, default is null string (means latest version)"
  default     = ""
}

variable "consul_instances_count" {
  description = "How many servers must come online. At this moment count cannot be changed"
  default     = 1
}

variable "consul_datacenter" {
  description = "Consul datacenter name"
  default     = "dc1"
}

variable "consul_instance_type" {
  description = "EC2 instance type: t2.micro, t3.medium, etc"
  default     = "t3.medium"
}


#
# Vault
#

variable "vault_enterprise_enabled" {
  description = "true => install Enterprise, false => install OSS"
  type        = bool
  default     = "false"
}

variable "vault_version" {
  description = "version to be used in format x.y.z, default is null string (means latest version)"
  default     = ""
}

variable "vault_instances_count" {
  description = "How many servers must come online"
  default     = 1
}

variable "vault_instance_type" {
  description = "EC2 instance type: t2.micro, t3.medium, etc"
  default     = "t3.medium"
}


#
# Client
#

variable "client_instance_type" {
  description = "EC2 instance type: t2.micro, t3.medium, etc"
  default     = "t3.medium"
}

variable "client_instances_count" {
  description = "How many servers must come online"
  default     = 1
}


#
# Bastion
#

variable "bastion_enable" {
  description = "true => install bastion host, false => do not install bastion host"
  type        = bool
  default     = "false"          # if set to `true` or `false`, use terraform apply; optionally `terraform output` for connection details
}