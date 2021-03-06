## install version + license
locals {
  consul_license = fileexists("${path.module}/licenses/consul.hclic") ? file("${path.module}/licenses/consul.hclic") : null
  nomad_license  = fileexists("${path.module}/licenses/nomad.hclic") ? file("${path.module}/licenses/nomad.hclic") : null
  vault_license  = fileexists("${path.module}/licenses/vault.hclic") ? file("${path.module}/licenses/vault.hclic") : null

  # if enterpise enabled pass string "-enteprise"
  consul_enterprise = var.consul_enterprise_enabled ? "-enterprise" : ""
  nomad_enterprise  = var.nomad_enterprise_enabled ? "-enterprise" : ""
  vault_enterprise  = var.vault_enterprise_enabled ? "-enterprise" : ""

  consul_enterprise_suffix = var.consul_enterprise_enabled ? "+ent" : ""
  nomad_enterprise_suffix  = var.nomad_enterprise_enabled ? "+ent" : ""
  vault_enterprise_suffix  = var.vault_enterprise_enabled ? "+ent" : ""

  # if version is provided pass the version, if enterprise enabled attach "+ent"
  consul_version = var.consul_version == "" ? "" : "=${var.consul_version}${local.consul_enterprise_suffix}"
  nomad_version  = var.nomad_version == "" ? "" : "=${var.nomad_version}${local.nomad_enterprise_suffix}"
  vault_version  = var.vault_version == "" ? "" : "=${var.vault_version}${local.vault_enterprise_suffix}"

  # eventually pass to installation strings like consul-enterprise=1.10.1+ent or nomad-enteprise=1.3.0+ent
  consul_install = "consul${local.consul_enterprise}${local.consul_version}"
  nomad_install  = "nomad${local.nomad_enterprise}${local.nomad_version}"
  vault_install  = "vault${local.vault_enterprise}${local.vault_version}"

  install = {
    consul = local.consul_install
    nomad  = local.nomad_install
    vault  = local.vault_install

  }
}

## consul
locals {
  vm_consul_vars_consul = {
    provider          = "aws"
    provider_region   = var.aws_default_region
    consul_bootstrap  = var.consul_instances_count
    consul_datacenter = var.consul_datacenter
    consul_tag_key    = "Project"
    consul_tag_value  = var.main_project_tag
    consul_license    = local.consul_license
  }

  vm_consul_cloud_init = <<-EOT
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MIMEBOUNDARY"

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-hashicorp-repository.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/install-consul.sh", local.install)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/install-nomad.sh", local.install)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-bash-env-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-bash-env-nomad.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/config-consul-server.sh", local.vm_consul_vars_consul)}
EOT
}

## nomad
locals {
  vm_nomad_vars_consul = {
    provider          = "aws"
    provider_region   = var.aws_default_region
    consul_datacenter = var.consul_datacenter
    consul_tag_key    = "Project"
    consul_tag_value  = var.main_project_tag
  }

  vm_nomad_vars_nomad = {
    provider         = "aws"
    provider_region  = var.aws_default_region
    nomad_bootstrap  = var.nomad_instances_count
    nomad_region     = var.nomad_region
    nomad_datacenter = var.nomad_datacenter
    nomad_tag_key    = "Project"
    nomad_tag_value  = var.main_project_tag
    nomad_license    = local.nomad_license
  }

  vm_nomad_cloud_init = <<-EOT
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MIMEBOUNDARY"

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-hashicorp-repository.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/install-consul.sh", local.install)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/install-nomad.sh", local.install)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-bash-env-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-bash-env-nomad.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/config-consul-client.sh", local.vm_nomad_vars_consul)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/config-nomad-server.sh", local.vm_nomad_vars_nomad)}
EOT
}

## vault
locals {
  vm_vault_vars_consul = {
    provider          = "aws"
    provider_region   = var.aws_default_region
    consul_bootstrap  = var.consul_instances_count
    consul_datacenter = var.consul_datacenter
    consul_tag_key    = "Project"
    consul_tag_value  = var.main_project_tag
  }

  vm_vault_vars_vault = {
    provider_region = var.aws_default_region
    kms_key         = "${aws_kms_key.vault.id}"
    provider_region = var.aws_default_region
    vault_tag_key   = "Project"
    vault_tag_value = "${var.main_project_tag}-vault"
    vault_license   = local.vault_license
  }

  vm_vault_cloud_init = <<-EOT
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MIMEBOUNDARY"

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-hashicorp-repository.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/install-consul.sh", local.install)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/install-vault.sh", local.install)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-bash-env-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-bash-env-vault.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/config-consul-client.sh", local.vm_vault_vars_consul)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/config-vault-server-raft.sh", local.vm_vault_vars_vault)}
EOT
}

## client
locals {
  vm_client_vars_consul = {
    provider          = "aws"
    provider_region   = var.aws_default_region
    consul_datacenter = var.consul_datacenter
    consul_tag_key    = "Project"
    consul_tag_value  = var.main_project_tag
  }

  vm_client_vars_nomad = {
    provider         = "aws"
    provider_region  = var.aws_default_region
    nomad_region     = var.nomad_region
    nomad_datacenter = var.nomad_datacenter
    nomad_tag_key    = "Project"
    nomad_tag_value  = var.main_project_tag
  }

  vm_client_cloud_init = <<-EOT
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MIMEBOUNDARY"

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-hashicorp-repository.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/install-consul.sh", local.install)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/install-nomad.sh", local.install)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-bash-env-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-bash-env-nomad.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-docker.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-cni.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/config-consul-client.sh", local.vm_client_vars_consul)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/config-nomad-client.sh", local.vm_client_vars_nomad)}
EOT
}

## traefik
locals {
  vm_traefik_vars_consul = {
    provider          = "aws"
    provider_region   = var.aws_default_region
    consul_datacenter = var.consul_datacenter
    consul_tag_key    = "Project"
    consul_tag_value  = var.main_project_tag
  }

  vm_traefik_cloud_init = <<-EOT
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MIMEBOUNDARY"

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-hashicorp-repository.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/install-consul.sh", local.install)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-bash-env-consul.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/install-traefik.sh")}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${templatefile("./cloud-init/config-consul-client.sh", local.vm_traefik_vars_consul)}

--MIMEBOUNDARY
Content-Type: text/x-shellscript
${file("./cloud-init/config-traefik.sh")}
EOT
}