resource "aws_instance" "bastion" {
  count                       = var.bastion_enable ? 1 : 0
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.public_key.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true

  tags = merge(
    { "Name" = "${var.main_project_tag}-bastion" },
    { "Project" = var.main_project_tag }
  )
}

resource "aws_instance" "consul" {
  count                  = var.consul_instances_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.consul_instance_type
  key_name               = aws_key_pair.public_key.id
  vpc_security_group_ids = [aws_security_group.any.id]
  subnet_id              = element(aws_subnet.private[*].id, count.index) # first instance 1st AZ, 2nd instance 2nd AZ etc
  iam_instance_profile   = aws_iam_instance_profile.cloud-auto-join.name

  tags = merge(
    { "Name" = "${var.main_project_tag}-consul" },
    { "Project" = var.main_project_tag }
  )

  user_data = local.consul_cloud_init
}

resource "aws_instance" "nomad" {
  count                  = var.nomad_instances_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.nomad_instance_type
  key_name               = aws_key_pair.public_key.id
  vpc_security_group_ids = [aws_security_group.any.id]
  subnet_id              = element(aws_subnet.private[*].id, count.index) # first instance 1st AZ, 2nd instance 2nd AZ etc
  iam_instance_profile   = aws_iam_instance_profile.cloud-auto-join.name

  tags = merge(
    { "Name" = "${var.main_project_tag}-nomad" },
    { "Project" = var.main_project_tag }
  )

  user_data = local.nomad_cloud_init
}

resource "aws_instance" "vault" {
  count                  = var.vault_instances_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.vault_instance_type
  key_name               = aws_key_pair.public_key.id
  vpc_security_group_ids = [aws_security_group.any.id]
  subnet_id              = element(aws_subnet.private[*].id, count.index) # first instance 1st AZ, 2nd instance 2nd AZ etc
  iam_instance_profile   = aws_iam_instance_profile.vault.name

  tags = merge(
    { "Name" = "${var.main_project_tag}-vault" },
    { "Project" = "${var.main_project_tag}-vault" }
  )

  user_data = local.vault_cloud_init
}

resource "aws_instance" "client" {
  count                  = var.client_instances_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.client_instance_type
  key_name               = aws_key_pair.public_key.id
  vpc_security_group_ids = [aws_security_group.any.id]
  subnet_id              = element(aws_subnet.private[*].id, count.index) # first instance 1st AZ, 2nd instance 2nd AZ etc
  iam_instance_profile   = aws_iam_instance_profile.cloud-auto-join.name

  tags = merge(
    { "Name" = "${var.main_project_tag}-client" },
    { "Project" = var.main_project_tag }
  )

  user_data = local.client_cloud_init
}