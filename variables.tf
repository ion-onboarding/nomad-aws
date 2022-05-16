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