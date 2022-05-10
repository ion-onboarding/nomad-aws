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
ui            = true
disable_mlock = true

cluster_addr = "http://{{ GetInterfaceIP \"ens5\" }}:8201"
api_addr     = "http://{{ GetInterfaceIP \"ens5\" }}:8200"

listener "tcp" {
  address     = "{{ GetInterfaceIP \"ens5\" }}:8200"
  tls_disable = "true"
}

seal "awskms" {
  region     = "${provider_region}"
  kms_key_id = "${kms_key}"
}

storage "raft" {
  path    = "/opt/vault/"
  node_id = "$PRIVATE_IP"
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

# query health endpoint: 200 - if initialized, unsealed, and active
IS_200=$(curl -sSL -D -  http://$PRIVATE_IP:8200/v1/sys/health | head -n 1 | cut -d' ' -f2)

# continue if HTTP status is 200
while [[ $IS_200 -ne 200 ]] ; do sleep 1; IS_200=$(curl -sSL -D -  http://$PRIVATE_IP:8200/v1/sys/health | head -n 1 | cut -d' ' -f2) ; done

# enable username/pasword authentication
vault auth enable userpass
vault write auth/userpass/users/admin password=admin policies=admin

# admin policy file - https://learn.hashicorp.com/tutorials/vault/policies
tee admin-policy.hcl <<EOF
# Read system health check
path "sys/health"
{
  capabilities = ["read", "sudo"]
}

# Create and manage ACL policies broadly across Vault

# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable and manage authentication methods broadly across Vault

# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# Enable and manage the key/value secrets engine at `secret/` path

# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}
EOF

# attach admin policy to admin
vault policy write admin admin-policy.hcl