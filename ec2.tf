resource "aws_instance" "bastion" {
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
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.consul_instance_type
  key_name               = aws_key_pair.public_key.id
  vpc_security_group_ids = [aws_security_group.any.id]
  subnet_id              = aws_subnet.private[0].id
  iam_instance_profile   = aws_iam_instance_profile.cloud-auto-join.name

  tags = merge(
    { "Name" = "${var.main_project_tag}-consul" },
    { "Project" = var.main_project_tag }
  )

  user_data_base64 = local.consul_cloud_init_gzip
}

resource "aws_instance" "nomad" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.nomad_instance_type
  key_name               = aws_key_pair.public_key.id
  vpc_security_group_ids = [aws_security_group.any.id]
  subnet_id              = aws_subnet.private[0].id
  iam_instance_profile   = aws_iam_instance_profile.cloud-auto-join.name

  tags = merge(
    { "Name" = "${var.main_project_tag}-nomad" },
    { "Project" = var.main_project_tag }
  )

  user_data_base64 = local.nomad_cloud_init_gzip
}

resource "aws_instance" "client" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.client_instance_type
  key_name               = aws_key_pair.public_key.id
  vpc_security_group_ids = [aws_security_group.any.id]
  subnet_id              = aws_subnet.private[1].id
  iam_instance_profile   = aws_iam_instance_profile.cloud-auto-join.name

  tags = merge(
    { "Name" = "${var.main_project_tag}-client" },
    { "Project" = var.main_project_tag }
  )

  user_data_base64 = local.client_cloud_init_gzip
}