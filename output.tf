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

  SSH_prometheus = var.bastion_enable ? [for prometheus in aws_instance.prometheus :
    "ssh -i ${local.private_key} -o StrictHostKeyChecking=no -J ubuntu@${aws_instance.bastion[0].public_ip} ubuntu@${prometheus.private_ip}"
  ] : null

  SSH_loki = var.bastion_enable ? [for loki in aws_instance.loki :
    "ssh -i ${local.private_key} -o StrictHostKeyChecking=no -J ubuntu@${aws_instance.bastion[0].public_ip} ubuntu@${loki.private_ip}"
  ] : null

  CONSUL_HTTP_ADDR = " export CONSUL_HTTP_ADDR='http://${aws_lb.alb_api.dns_name}:8500' "
  NOMAD_ADDR       = " export NOMAD_ADDR='http://${aws_lb.alb_api.dns_name}:4646' "
  VAULT_ADDR       = " export VAULT_ADDR='http://${aws_lb.alb_api.dns_name}:8200' "

  USER_credentials = ["VAULT_UI = admin/admin", "GRAFANA_UI = admin/admin"]

  WWW_lb                = " http://${aws_lb.alb_api.dns_name}:80 "
  WWW_grafana           = " http://${aws_lb.alb_api.dns_name}:3000 "
  WWW_prometheus        = " http://${aws_lb.alb_api.dns_name}:9090 "
  WWW_traefik_dashboard = " http://${aws_lb.alb_api.dns_name}:8080 "
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

output "SSH_prometheus" {
  value = local.WWW_prometheus
}

output "SSH_loki" {
  value = local.SSH_loki
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

output "USER_credentials" {
  value = local.USER_credentials
}

output "WWW_LB" {
  value = local.WWW_lb
}

output "WWW_grafana" {
  value = local.WWW_grafana
}

output "WWW_traefik_dashboard" {
  value = local.WWW_traefik_dashboard
}