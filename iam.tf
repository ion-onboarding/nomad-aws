#
# Nomad, Consul
#
resource "random_pet" "env_cloud_auto_join" {
  length = 1
  separator = "-"
  prefix      = var.main_project_tag
}

resource "aws_iam_instance_profile" "cloud_auto_join" {
  name_prefix = random_pet.env_cloud_auto_join.id
  role        = aws_iam_role.auto_join.name
}

# IAM role
resource "aws_iam_role" "auto_join" {
  name_prefix        = random_pet.env_cloud_auto_join.id
  assume_role_policy = data.aws_iam_policy_document.who_can_use.json
}

# who can use this role?
data "aws_iam_policy_document" "who_can_use" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# creates IAM policy for cluster discovery
resource "aws_iam_role_policy" "what_can_do_cluster_discovery" {
  name_prefix   = random_pet.env_cloud_auto_join.id
  role   = aws_iam_role.auto_join.id
  policy = data.aws_iam_policy_document.what_can_do_cluster_discovery.json
}

# creates IAM policy document for linking to above policy as JSON
data "aws_iam_policy_document" "what_can_do_cluster_discovery" {
  # allow role with this policy to do the following: list instances, list tags
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
}

#
# Vault
#
resource "random_pet" "env_unseal_cloud_auto_join" {
  length = 1
    separator = "-"
  prefix      = var.main_project_tag
}

resource "aws_iam_instance_profile" "unseal_cloud_auto_join" {
  name_prefix = random_pet.env_unseal_cloud_auto_join.id
  role        = aws_iam_role.unseal_cloud_auto_join.name
}

# IAM role
resource "aws_iam_role" "unseal_cloud_auto_join" {
  name_prefix        = random_pet.env_unseal_cloud_auto_join.id
  assume_role_policy = data.aws_iam_policy_document.who_can_use_vault.json
}

# who can use this role?
data "aws_iam_policy_document" "who_can_use_vault" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# creates IAM policy for cluster discovery
resource "aws_iam_role_policy" "what_can_do_vault_cluster_discovery" {
  name_prefix   = random_pet.env_unseal_cloud_auto_join.id
  role   = aws_iam_role.unseal_cloud_auto_join.id
  policy = data.aws_iam_policy_document.what_can_do_vault_cluster_discovery.json
}

# creates IAM policy document for linking to above policy as JSON
data "aws_iam_policy_document" "what_can_do_vault_cluster_discovery" {
  # allow role with this policy to do the following: list instances, list tags
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
}

# creates IAM policy for unsealing vault
resource "aws_iam_role_policy" "what_can_do_vault_unseal" {
  name_prefix   = random_pet.env_unseal_cloud_auto_join.id
  role   = aws_iam_role.unseal_cloud_auto_join.id
  policy = data.aws_iam_policy_document.what_can_do_vault_unseal.json
}

# creates IAM policy document for linking to above policy as JSON
data "aws_iam_policy_document" "what_can_do_vault_unseal" {
  # allow role with this policy to do the following: use keys (describe, encrypt, decrypt) to unseal vault
  statement {
    effect = "Allow"

    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
    ]

    resources = [
      "*"
    ]
  }
}