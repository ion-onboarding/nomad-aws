data "aws_availability_zones" "available" {
  state = "available"
  # https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeAvailabilityZones.html
  filter {
    name   = "region-name"
    values = [var.aws_default_region]
  }
}

data "aws_ami" "ubuntu-20-focal" {
  most_recent = true

  # https://wiki.ubuntu.com/Releases
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_ami" "ubuntu-22-jammy" {
  most_recent = true

  # https://wiki.ubuntu.com/Releases
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # awscli: aws ec2 describe-images --owners 099720109477
  owners = ["099720109477"] # Canonical
}