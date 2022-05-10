provider "aws" {
  region = var.aws_default_region
}

locals {
  public_key = fileexists("~/.ssh/id_ed25519.pub") ? file("~/.ssh/id_ed25519.pub") : file("~/.ssh/id_rsa.pub")
}

resource "aws_key_pair" "public_key" {
  key_name_prefix = var.main_project_tag
  public_key      = local.public_key

  tags = merge(
    { "Name" = "${var.main_project_tag}-bastion" },
    { "Project" = var.main_project_tag }
  )
}

resource "aws_kms_key" "vault" {
  description         = "unseal vault"
  enable_key_rotation = false
  is_enabled          = true

  tags = merge(
    { "Name" = "${var.main_project_tag}-unseal-vault" },
    { "Project" = var.main_project_tag }
  )
}