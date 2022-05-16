#!/usr/bin/env bash

# installed before configuration
while [ ! -f /usr/bin/vault ]; do sleep 1; done

# license
tee /etc/vault.d/vault.hclic > /dev/null <<EOF
${vault_license}
EOF

# empty default config
echo "" | tee /etc/vault.d/vault.hcl

# directory integrated storage
mkdir -p /opt/vault/
chown vault:vault /opt/vault/

# configuration file
tee /etc/vault.d/vault.hcl > /dev/null <<EOF
# vault server config
ui            = true
disable_mlock = true

# if OSS binary is used then the license configuration is ignored
license_path = "/etc/vault.d/vault.hclic"

cluster_addr = "http://{{ GetInterfaceIP \"ens5\" }}:8201"
api_addr     = "http://{{ GetInterfaceIP \"ens5\" }}:8200"

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

seal "awskms" {
  region     = "${provider_region}"
  kms_key_id = "${kms_key}"
}

storage "raft" {
  path    = "/opt/vault/data"
  node_id = "$PRIVATE_IP"

  retry_join {
    auto_join         = "provider=aws region=${provider_region} tag_key=${vault_tag_key} tag_value=${vault_tag_value}"
    auto_join_scheme  = "http"
  }
}
EOF

# vault is a service
systemctl enable vault
systemctl start vault

# pull IP
export PRIVATE_IP=$(curl -sS http://169.254.169.254/latest/meta-data/local-ipv4)

export VAULT_ADDR=http://$PRIVATE_IP:8200

# unseal only one instance
if [[ $(curl http://169.254.169.254/latest/meta-data/tags/instance/instance-number/) -eq 0 ]] ; then
# wait untill vault status returns 2 (sealed), https://www.vaultproject.io/docs/commands/status
while vault status ; ret=$? ; [ $ret -ne 2 ];do sleep 1; done

# root token & recovery keys
vault operator init > /etc/vault.d/unseal.txt

# extract root token
export VAULT_TOKEN=$(cat /etc/vault.d/unseal.txt | grep -i token | cut -d' ' -f4)

# wait till vault status returns 0 (unsealed), https://www.vaultproject.io/docs/commands/status
while vault status ; ret=$? ; [ $ret -ne 0 ];do sleep 1; done

# query health endpoint: 200 - if initialized, unsealed, and active
IS_200=$(curl -sSL -D -  http://$PRIVATE_IP:8200/v1/sys/health | head -n 1 | cut -d' ' -f2)

# continue if HTTP status is 200
while [[ $IS_200 -ne 200 ]] ; do sleep 1; IS_200=$(curl -sSL -D -  http://$PRIVATE_IP:8200/v1/sys/health | head -n 1 | cut -d' ' -f2) ; done

# create a policy with any path allowing all capabilities (root)
tee root-policy.hcl <<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

# attach admin policy to admin
vault policy write admin-root root-policy.hcl
fi

# enable username/pasword authentication
vault auth enable userpass
vault write auth/userpass/users/admin password=admin policies=admin-root