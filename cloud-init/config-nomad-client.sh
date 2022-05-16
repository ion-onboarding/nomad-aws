#!/usr/bin/env bash

# nomad installed before configuration
while [ ! -f /usr/bin/nomad ]; do sleep 1; done

# empty default config
echo "" | tee /etc/nomad.d/nomad.hcl

# nomad client
tee /etc/nomad.d/nomad.hcl > /dev/null <<EOF
region = "${nomad_region}"
datacenter = "${nomad_datacenter}"
data_dir = "/opt/nomad"

bind_addr = "{{ GetInterfaceIP \"ens5\" }}"

client {
  enabled = true

  server_join {
    retry_join = ["provider=${provider} region=${provider_region} tag_key=${nomad_tag_key} tag_value=${nomad_tag_value}"]
    retry_max = 5
    retry_interval = "15s"
  }
  
  options = {
    "driver.raw_exec" = "1"
    "driver.raw_exec.enable" = "1"
  }
}

consul {
  address = "127.0.0.1:8500"
}
EOF

# start nomad
systemctl enable nomad
systemctl start nomad