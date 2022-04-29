#!/usr/bin/env bash

# consul server
tee /etc/consul.d/consul.hcl > /dev/null <<EOF
# consul server config
datacenter = "${consul_datacenter}"
data_dir = "/opt/consul"

bind_addr = "{{ GetInterfaceIP \"ens5\" }}"
client_addr = "0.0.0.0"

server = true
bootstrap_expect = ${consul_bootstrap}

retry_join = ["provider=${provider} region=${provider_region} tag_key=${consul_tag_key} tag_value=${consul_tag_value}"]
retry_max = 5
retry_interval = "15s"

# Consul UI
ui_config {
    enabled = true
}

# service mesh
connect {
  enabled = true
}

addresses {
  grpc = "127.0.0.1"
}

ports {
  grpc  = 8502
}
EOF

# start consul
systemctl enable consul
systemctl start consul