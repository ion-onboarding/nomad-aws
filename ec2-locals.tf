## consul cloud init
locals {
  consul_vars_consul = {
    provider          = "aws"
    provider_region   = var.aws_default_region
    consul_bootstrap  = var.consul_instances_count
    consul_datacenter = var.consul_datacenter
    consul_tag_key    = "Project"
    consul_tag_value  = var.main_project_tag
  }

  consul_cloud_init = <<-EOT
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MIMEBOUNDARY"

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-hashicorp-repository.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-nomad.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-bash-env-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-bash-env-nomad.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./scripts/config-consul-server.sh", local.consul_vars_consul)}
EOT
}

## nomad clount init
locals {
  nomad_vars_consul = {
    provider          = "aws"
    provider_region   = var.aws_default_region
    consul_datacenter = var.consul_datacenter
    consul_tag_key    = "Project"
    consul_tag_value  = var.main_project_tag
  }

  nomad_vars_nomad = {
    provider         = "aws"
    provider_region  = var.aws_default_region
    nomad_bootstrap  = var.nomad_instances_count
    nomad_region     = var.nomad_region
    nomad_datacenter = var.nomad_datacenter
    nomad_tag_key    = "Project"
    nomad_tag_value  = var.main_project_tag
  }

  nomad_cloud_init = <<-EOT
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MIMEBOUNDARY"

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-hashicorp-repository.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-nomad.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-bash-env-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-bash-env-nomad.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./scripts/config-consul-client.sh", local.nomad_vars_consul)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./scripts/config-nomad-server.sh", local.nomad_vars_nomad)}
EOT
}

## vault cloud init
locals {
  vault_vars_consul = {
    provider          = "aws"
    provider_region   = var.aws_default_region
    consul_bootstrap  = var.consul_instances_count
    consul_datacenter = var.consul_datacenter
    consul_tag_key    = "Project"
    consul_tag_value  = var.main_project_tag
  }

  vault_vars_vault = {
    provider        = "aws"
    provider_region = var.aws_default_region
    vault_tag_key   = "Project"
    vault_tag_value = var.main_project_tag
    kms_key         = "${aws_kms_key.vault.id}"
  }

  vault_cloud_init = <<-EOT
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MIMEBOUNDARY"

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-hashicorp-repository.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-vault.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-bash-env-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-bash-env-vault.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./scripts/config-consul-client.sh", local.vault_vars_consul)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./scripts/config-vault-server.sh", local.vault_vars_vault)}
EOT
}

## client cloud init
locals {
  client_vars_consul = {
    provider          = "aws"
    provider_region   = var.aws_default_region
    consul_datacenter = var.consul_datacenter
    consul_tag_key    = "Project"
    consul_tag_value  = var.main_project_tag
  }

  client_vars_nomad = {
    provider         = "aws"
    provider_region  = var.aws_default_region
    nomad_region     = var.nomad_region
    nomad_datacenter = var.nomad_datacenter
    nomad_tag_key    = "Project"
    nomad_tag_value  = var.main_project_tag
  }

  client_cloud_init = <<-EOT
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MIMEBOUNDARY"

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-hashicorp-repository.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-nomad.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-bash-env-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-bash-env-nomad.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-docker.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./scripts/install-cni.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./scripts/config-consul-client.sh", local.client_vars_consul)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./scripts/config-nomad-client.sh", local.client_vars_nomad)}
EOT
}