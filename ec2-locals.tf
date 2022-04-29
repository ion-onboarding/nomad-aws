## Consul cloud init
locals {
  consul_cloud_init_parts = [
    {
      filepath     = "./scripts/install-hashicorp-repository.sh"
      content-type = "text/cloud-boothook"
      vars         = {}
    },
    {
      filepath     = "./scripts/install-consul.sh"
      content-type = "text/cloud-boothook"
      vars         = {}
    },
    {
      filepath     = "./scripts/install-bash-environment.sh"
      content-type = "text/x-shellscript"
      vars         = {}
    },
    {
      filepath     = "./scripts/config-consul-server.sh"
      content-type = "text/x-shellscript"
      vars = {
        provider          = "aws"
        provider_region   = var.aws_default_region
        consul_bootstrap  = var.consul_instances_count
        consul_datacenter = var.consul_datacenter
        consul_tag_key    = "Project"
        consul_tag_value  = var.main_project_tag
      }
    },
  ]

  consul_cloud_init_parts_rendered = [for part in local.consul_cloud_init_parts : <<-EOF
            --MIMEBOUNDARY
            Content-Transfer-Encoding: 7bit
            Content-Type: ${part.content-type}
            Mime-Version: 1.0

            ${templatefile(part.filepath, part.vars)}
            EOF
  ]

  consul_cloud_init_gzip = base64gzip(templatefile("./scripts/cloud-init.tftpl", { cloud_init_parts = local.consul_cloud_init_parts_rendered }))
}

## Nomad cloud init
locals {
  nomad_cloud_init_parts = [
    {
      filepath     = "./scripts/install-hashicorp-repository.sh"
      content-type = "text/cloud-boothook"
      vars         = {}
    },
    {
      filepath     = "./scripts/install-consul.sh"
      content-type = "text/cloud-boothook"
      vars         = {}
    },
    {
      filepath     = "./scripts/install-nomad.sh"
      content-type = "text/cloud-boothook"
      vars         = {}
    },
    {
      filepath     = "./scripts/install-bash-environment.sh"
      content-type = "text/x-shellscript"
      vars         = {}
    },
    {
      filepath     = "./scripts/install-bash-environment.sh"
      content-type = "text/x-shellscript"
      vars         = {}
    },
    {
      filepath     = "./scripts/config-consul-client.sh"
      content-type = "text/x-shellscript"
      vars = {
        provider          = "aws"
        provider_region   = var.aws_default_region
        consul_datacenter = var.consul_datacenter
        consul_tag_key    = "Project"
        consul_tag_value  = var.main_project_tag
      }
    },
    {
      filepath     = "./scripts/config-nomad-server.sh"
      content-type = "text/x-shellscript"
      vars = {
        provider         = "aws"
        provider_region  = var.aws_default_region
        nomad_bootstrap  = var.nomad_instances_count
        nomad_region     = var.nomad_region
        nomad_datacenter = var.nomad_datacenter
        nomad_tag_key    = "Project"
        nomad_tag_value  = var.main_project_tag
      }
    },
  ]

  nomad_cloud_init_parts_rendered = [for part in local.nomad_cloud_init_parts : <<-EOF
            --MIMEBOUNDARY
            Content-Transfer-Encoding: 7bit
            Content-Type: ${part.content-type}
            Mime-Version: 1.0
            ${templatefile(part.filepath, part.vars)}
            EOF
  ]

  nomad_cloud_init_gzip = base64gzip(templatefile("./scripts/cloud-init.tftpl", { cloud_init_parts = local.nomad_cloud_init_parts_rendered }))
}

## Client cloud init
locals {
  client_cloud_init_parts = [
    {
      filepath     = "./scripts/install-hashicorp-repository.sh"
      content-type = "text/cloud-boothook"
      vars         = {}
    },
    {
      filepath     = "./scripts/install-consul.sh"
      content-type = "text/cloud-boothook"
      vars         = {}
    },
    {
      filepath     = "./scripts/install-nomad.sh"
      content-type = "text/cloud-boothook"
      vars         = {}
    },
    {
      filepath     = "./scripts/install-bash-environment.sh"
      content-type = "text/x-shellscript"
      vars         = {}
    },
    {
      filepath     = "./scripts/install-docker.sh"
      content-type = "text/x-shellscript"
      vars         = {}
    },
    {
      filepath     = "./scripts/config-nomad-cni.sh"
      content-type = "text/x-shellscript"
      vars         = {}
    },
    {
      filepath     = "./scripts/config-consul-client.sh"
      content-type = "text/x-shellscript"
      vars = {
        provider          = "aws"
        provider_region   = var.aws_default_region
        consul_datacenter = var.consul_datacenter
        consul_tag_key    = "Project"
        consul_tag_value  = var.main_project_tag
      }
    },
    {
      filepath     = "./scripts/config-nomad-client.sh"
      content-type = "text/x-shellscript"
      vars = {
        provider         = "aws"
        provider_region  = var.aws_default_region
        nomad_region     = var.nomad_region
        nomad_datacenter = var.nomad_datacenter
        nomad_tag_key    = "Project"
        nomad_tag_value  = var.main_project_tag
      }
    },
  ]

  client_cloud_init_parts_rendered = [for part in local.client_cloud_init_parts : <<-EOF
            --MIMEBOUNDARY
            Content-Transfer-Encoding: 7bit
            Content-Type: ${part.content-type}
            Mime-Version: 1.0
            ${templatefile(part.filepath, part.vars)}
            EOF
  ]

  client_cloud_init_gzip = base64gzip(templatefile("./scripts/cloud-init.tftpl", { cloud_init_parts = local.client_cloud_init_parts_rendered }))
}