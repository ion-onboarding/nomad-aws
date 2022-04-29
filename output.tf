locals {
  private_key = fileexists("~/.ssh/id_ed25519") ? "~/.ssh/id_ed25519" : "~/.ssh/id_rsa"
}

output "SSH_bation" {
  value = "ssh -i ${local.private_key} -o 'StrictHostKeyChecking=no' ubuntu@${aws_instance.bastion.public_ip}"
}

output "WWW_alb_consul" {
    value = "http://${aws_lb.alb_consul.dns_name}"
}

output "WWW_alb_nomad" {
    value = "http://${aws_lb.alb_nomad.dns_name}"
}

output "SSH_internal_consul" {
  value = "ssh -i ${local.private_key} -o 'StrictHostKeyChecking=no' -J ubuntu@${aws_instance.bastion.public_ip} ubuntu@${aws_instance.consul.private_ip}"
}

output "SSH_internal_nomad" {
  value = "ssh -i ${local.private_key} -o 'StrictHostKeyChecking=no' -J ubuntu@${aws_instance.bastion.public_ip} ubuntu@${aws_instance.bastion.private_ip}"
}

output "SSH_internal_client" {
  value = "ssh -i ${local.private_key} -o 'StrictHostKeyChecking=no' -J ubuntu@${aws_instance.bastion.public_ip} ubuntu@${aws_instance.client.private_ip}"
}
