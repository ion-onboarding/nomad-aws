#!/usr/bin/env bash

# loki installed before configuration
while [ ! -f /usr/sbin/grafana-server ]; do sleep 1; done

# backup existing default config
mv /etc/grafana/grafana.ini /etc/grafana/grafana.ini.backup

tee /etc/grafana/grafana.ini > /dev/null <<EOF
[server]
root_url = ${root_url}
EOF

# start grafana
systemctl enable grafana-server
systemctl start grafana-server
