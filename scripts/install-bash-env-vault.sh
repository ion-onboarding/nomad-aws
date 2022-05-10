#!/usr/bin/env bash

# wait for token in the unseal.txt file
# while [ ! -f /etc/consul.d/unseal.txt ]; do sleep 1; done

# system wide environment variables - https://help.ubuntu.com/community/EnvironmentVariables#A.2Fetc.2Fprofile.d.2F.2A.sh
tee /etc/profile.d/bash-hashicorp-env-vault.sh > /dev/null <<EOF
export VAULT_ADDR=http://$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4):8200
export VAULT_TOKEN=$(cat /etc/vault.d/unseal.txt | grep -i token | cut -d' ' -f4)

# autocomplete
complete -C /usr/bin/vault vault
EOF