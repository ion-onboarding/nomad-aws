#!/usr/bin/env bash

# loki installed before configuration
while [ ! -f /usr/sbin/grafana-server ]; do sleep 1; done

# backup existing default config
mv /etc/grafana/grafana.ini /etc/grafana/grafana.ini.backup

# basic grafana configuration
tee /etc/grafana/grafana.ini > /dev/null <<EOF
[server]
root_url = ${root_url}

[security]
admin_user = admin
admin_password = admin
EOF

# add prometheus as datasource to grafana
tee /etc/grafana/provisioning/datasources/datasource-prometheus.yml > /dev/null <<EOF
# config file version
apiVersion: 1

datasources:
- name: prometheus
  type: prometheus
  access: server
  orgId: 1
  url: ${prometheus_url}
EOF

# start grafana
systemctl enable grafana-server
systemctl start grafana-server
