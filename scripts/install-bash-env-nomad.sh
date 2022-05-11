#!/usr/bin/env bash

# system wide environment variables - https://help.ubuntu.com/community/EnvironmentVariables#A.2Fetc.2Fprofile.d.2F.2A.sh
tee /etc/profile.d/bash-hashicorp-env-nomad.sh > /dev/null <<EOF
export NOMAD_ADDR=http://$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4):4646

# autocomplete
complete -C /usr/bin/nomad nomad
EOF