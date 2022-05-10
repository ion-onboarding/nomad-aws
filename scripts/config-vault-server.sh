#!/usr/bin/env bash

# installed before configuration
while [ ! -f /usr/bin/vault ]; do sleep 1; done

# empty default config
echo "" | tee /etc/vault.d/vault.hcl

# directory integrated storage
mkdir -p /opt/vault/
chown vault:vault /opt/vault/
PRIVATE_IP=$(curl -sS http://169.254.169.254/latest/meta-data/local-ipv4)
# configuration file
tee /etc/vault.d/vault.hcl > /dev/null <<EOF
ui = true
disable_mlock = true

cluster_addr  = "http://{{ GetInterfaceIP \"ens5\" }}:8201"
api_addr      = "http://{{ GetInterfaceIP \"ens5\" }}:8200"

listener "tcp" {
  address            = "{{ GetInterfaceIP \"ens5\" }}:8200"
  tls_disable      = "true"
}

seal "awskms" {
  region="${provider_region}"
  kms_key_id = "${kms_key}"
}

storage "raft" {
  path    = "/opt/vault/"
  node_id = "$PRIVATE_IP"

  retry_join {
    auto_join = "provider=${provider} region=${provider_region} tag_key=${vault_tag_key} tag_value=${vault_tag_value}-vault"
    auto_join_scheme = "http"
    auto_join_port = 8200
  }
}
EOF

systemctl enable vault
systemctl start vault

# unseal
export VAULT_ADDR=http://$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4):8200

# wait untill vault status returns 2 (sealed), https://www.vaultproject.io/docs/commands/status
while vault status ; ret=$? ; [ $ret -ne 2 ];do echo sleep ; sleep 1; done

# root token & recovery keys
vault operator init > /etc/vault.d/unseal.txt

# extract root token
export VAULT_TOKEN=$(cat /etc/vault.d/unseal.txt | grep -i token | cut -d' ' -f4)

# wait till vault status returns 0 (unsealed), https://www.vaultproject.io/docs/commands/status
while vault status ; ret=$? ; [ $ret -ne 0 ];do echo sleep ; sleep 1; done

# pull IP
PRIVATE_IP=$(curl -sS http://169.254.169.254/latest/meta-data/local-ipv4)

# query health endpoint, 200 if initialized, unsealed, and active
IS_200=$(curl -sSL -D -  http://$PRIVATE_IP:8200/v1/sys/health | head -n 1 | cut -d' ' -f2)

# continue if HTTP status is 200
while [[ $IS_200 -ne 200 ]] ; do sleep 1; IS_200=$(curl -sSL -D -  http://$PRIVATE_IP:8200/v1/sys/health | head -n 1 | cut -d' ' -f2) ; done

# enable username/pasword authentication
vault auth enable userpass
vault write auth/userpass/users/admin password=admin policies=admins