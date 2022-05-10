resource "aws_iam_instance_profile" "vault" {
  name_prefix = "vault"
  role        = aws_iam_role.instance_role_vault.name
}

resource "aws_iam_role" "instance_role_vault" {
  name_prefix        = "vault"
  assume_role_policy = data.aws_iam_policy_document.instance_role_vault.json
}

data "aws_iam_policy_document" "instance_role_vault" {
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

resource "aws_iam_role_policy" "cloud_auto_join" {
  name   = "vault-auto-join"
  role   = aws_iam_role.instance_role_vault.id
  policy = data.aws_iam_policy_document.cloud_auto_join.json
}

data "aws_iam_policy_document" "cloud_auto_join" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "auto_unseal" {
  name   = "vault-auto-unseal"
  role   = aws_iam_role.instance_role_vault.id
  policy = data.aws_iam_policy_document.auto_unseal.json
}

data "aws_iam_policy_document" "auto_unseal" {
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

# resource "aws_iam_role_policy" "session_manager" {
#   name   = "vault-ssm"
#   role   = aws_iam_role.instance_role_vault.id
#   policy = data.aws_iam_policy_document.session_manager.json
# }

# data "aws_iam_policy_document" "session_manager" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "ssm:UpdateInstanceInformation",
#       "ssmmessages:CreateControlChannel",
#       "ssmmessages:CreateDataChannel",
#       "ssmmessages:OpenControlChannel",
#       "ssmmessages:OpenDataChannel"
#     ]

#     resources = [
#       "*",
#     ]
#   }
# }

# resource "aws_iam_role_policy" "secrets_manager" {
#   name   = "vault-secrets-manager"
#   role   = aws_iam_role.instance_role_vault.id
#   policy = data.aws_iam_policy_document.secrets_manager.json
# }

# data "aws_iam_policy_document" "secrets_manager" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "secretsmanager:GetSecretValue",
#     ]

#     resources = [
#       "*"
#     ]
#   }
# }