#!/usr/bin/env bash

# loki installed before configuration
while [ ! -f /usr/bin/promtail-linux-amd64 ]; do sleep 1; done

# config example from https://raw.githubusercontent.com/grafana/loki/master/cmd/loki/loki-local-config.yaml
mkdir -p /etc/promtail/
tee /etc/promtail/config-promtail.yml > /dev/null <<EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: 'http://localhost:3100/loki/api/v1/push'

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*log
EOF

sudo useradd --system promtail
chown -R promtail:promtail /etc/promtail/config-promtail.yml

# promtail is a service
tee /etc/systemd/system/promtail.service > /dev/null <<EOF
[Unit]
Description=Promtail service
After=network.target

[Service]
Type=simple
User=promtail
ExecStart=/usr/bin/promtail-linux-amd64 -config.file /etc/promtail/config-promtail.yml

[Install]
WantedBy=multi-user.target
EOF

# promtail needs to read system logs
usermod -a -G adm promtail

systemctl enable promtail
systemctl start promtail

# test with: curl 127.0.0.1:9080/metrics
