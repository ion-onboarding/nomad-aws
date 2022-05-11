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

  SSH_traefik = var.bastion_enable ? [for traefik in aws_instance.traefik :
    "ssh -i ${local.private_key} -o StrictHostKeyChecking=no -J ubuntu@${aws_instance.bastion[0].public_ip} ubuntu@${traefik.private_ip}"
  ] : null

  CONSUL_HTTP_ADDR        = " export CONSUL_HTTP_ADDR='http://${aws_lb.alb_api.dns_name}:8500' "
  NOMAD_ADDR              = " export NOMAD_ADDR='http://${aws_lb.alb_api.dns_name}:4646' "
  VAULT_ADDR              = " export VAULT_ADDR='http://${aws_lb.alb_api.dns_name}:8200' "
  VAULT_GUI_user_password = "admin/admin"
  WWW_TRAEFIK_dashboard   = "http://${aws_lb.alb_api.dns_name}:8080"
  URL_LoadBalancer        = aws_lb.alb_api.dns_name
}

output "SSH_bation" {
  value = local.SSH_bastion
}

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

output "SSH_traefik" {
  value = local.SSH_traefik
}

output "CONSUL_HTTP_ADDR" {
  value = local.CONSUL_HTTP_ADDR
}

output "NOMAD_ADDR" {
  value = local.NOMAD_ADDR
}

output "VAULT_ADDR" {
  value = local.VAULT_ADDR
}

output "VAULT_GUI_user_password" {
  value = local.VAULT_GUI_user_password
}

output "WWW_TRAEFIK_dashboard" {
  value = local.WWW_TRAEFIK_dashboard
}

output "URL_LoadBalancer" {
  value = local.URL_LoadBalancer
}