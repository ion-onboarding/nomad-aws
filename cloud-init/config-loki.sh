#!/usr/bin/env bash

# loki installed before configuration
while [ ! -f /usr/bin/loki-linux-amd64 ]; do sleep 1; done

# config example from https://raw.githubusercontent.com/grafana/loki/master/cmd/loki/loki-local-config.yaml
mkdir -p /etc/loki/
tee /etc/loki/loki-local-config.yaml > /dev/null <<EOF
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  path_prefix: /tmp/loki
  storage:
    filesystem:
      chunks_directory: /tmp/loki/chunks
      rules_directory: /tmp/loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://localhost:9093
EOF

sudo useradd --system loki
chown -R loki:loki /etc/loki/loki-local-config.yaml

# loki is a service
tee /etc/systemd/system/loki.service > /dev/null <<EOF
[Unit]
Description=Loki service
After=network.target

[Service]
Type=simple
User=loki
ExecStart=/usr/bin/loki-linux-amd64 -config.file /etc/loki/loki-local-config.yaml

[Install]
WantedBy=multi-user.target
EOF

systemctl enable loki
systemctl start loki