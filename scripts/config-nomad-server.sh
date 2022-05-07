#!/usr/bin/env bash

# nomad installed before configuration
while [ ! -f /usr/bin/nomad ]; do sleep 1; done

# empty default config
echo "" | tee /etc/nomad.d/nomad.hcl

# nomad server
tee /etc/nomad.d/nomad.hcl > /dev/null <<EOF
region = "${nomad_region}"
datacenter = "${nomad_datacenter}"
data_dir = "/opt/nomad"

bind_addr = "{{ GetInterfaceIP \"ens5\" }}"

server {
  enabled = true
  raft_protocol = 3
  bootstrap_expect = ${nomad_bootstrap}
  
  server_join {
    retry_join = ["provider=${provider} region=${provider_region} tag_key=${nomad_tag_key} tag_value=${nomad_tag_value}"]
    retry_max = 5
    retry_interval = "15s"
  }
}

consul {
  address = "127.0.0.1:8500"
}

EOF

# start nomad
systemctl enable nomad
systemctl start nomad