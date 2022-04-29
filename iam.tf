resource "random_id" "environment_name" {
  byte_length = 4
  prefix      = var.main_project_tag
}

resource "aws_iam_instance_profile" "cloud-auto-join" {
  name_prefix = random_id.environment_name.hex
  role        = aws_iam_role.instance_role.name
}

# creates IAM role for instances using supplied policy from data source below
resource "aws_iam_role" "instance_role" {
  name_prefix        = random_id.environment_name.hex
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

# defines JSON for instance role base IAM policy
data "aws_iam_policy_document" "instance_role" {
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

# creates IAM role policy for cluster discovery and attaches it to instance role
resource "aws_iam_role_policy" "cluster_discovery" {
  name   = random_id.environment_name.hex
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.cluster_discovery.json
}

# creates IAM policy document for linking to above policy as JSON
data "aws_iam_policy_document" "cluster_discovery" {
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