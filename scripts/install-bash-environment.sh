#!/usr/bin/env bash

# system wide configure nomad & consul HTTP ADDRESS
# https://help.ubuntu.com/community/EnvironmentVariables#A.2Fetc.2Fprofile.d.2F.2A.sh
tee /etc/profile.d/bash-hashicorp-environment.sh > /dev/null <<EOF
#nomad
export NOMAD_ADDR=http://$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4):4646

# consul
export CONSUL_HTTP_ADDR=http://$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4):8500

# autocomplete
complete -C /usr/bin/nomad nomad
complete -C /usr/bin/consul consul

EOF