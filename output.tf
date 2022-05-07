locals {
  private_key = fileexists("~/.ssh/id_ed25519") ? "~/.ssh/id_ed25519" : "~/.ssh/id_rsa"

  SSH_bastion = var.bastion_enable ? "ssh -i ${local.private_key} -o StrictHostKeyChecking=no ubuntu@${aws_instance.bastion[0].public_ip}" : null

  SSH_nomad = var.bastion_enable ? [for nomad in aws_instance.nomad :
    "ssh -i ${local.private_key} -o StrictHostKeyChecking=no -J ubuntu@${aws_instance.bastion[0].public_ip} ubuntu@${nomad.private_ip}"
  ] : null

  SSH_consul = var.bastion_enable ? [for consul in aws_instance.consul :
    "ssh -i ${local.private_key} -o StrictHostKeyChecking=no -J ubuntu@${aws_instance.bastion[0].public_ip} ubuntu@${consul.private_ip}"
  ] : null

  SSH_vault = var.bastion_enable ? [for vault in aws_instance.vault :
    "ssh -i ${local.private_key} -o StrictHostKeyChecking=no -J ubuntu@${aws_instance.bastion[0].public_ip} ubuntu@${vault.private_ip}"
  ] : null

  SSH_client = var.bastion_enable ? [for client in aws_instance.client :
    "ssh -i ${local.private_key} -o StrictHostKeyChecking=no -J ubuntu@${aws_instance.bastion[0].public_ip} ubuntu@${client.private_ip}"
  ] : null
}

# output "SSH_bation" {
#   value = local.SSH_bastion
# }

output "SSH_nomad" {
  value = local.SSH_nomad
}

output "SSH_consul" {
  value = local.SSH_consul
}

output "SSH_vault" {
  value = local.SSH_vault
}

output "SSH_client" {
  value = local.SSH_client
}

# output "WWW_alb_consul" {
#   value = "http://${aws_lb.alb_consul.dns_name}"
# }

# output "WWW_alb_nomad" {
#   value = "http://${aws_lb.alb_nomad.dns_name}"
# }


# output "CONSUL_HTTP_ADDR" {
#   value = "export CONSUL_HTTP_ADDR=http://${aws_lb.alb_consul.dns_name}:80"
# }

# output "NOMAD_ADDR" {
#   value = "export NOMAD_ADDR=http://${aws_lb.alb_nomad.dns_name}:80"
# }

output "WWW_alb_api" {
  value = "http://${aws_lb.alb_api.dns_name}"
}
