#!/usr/bin/env bash

# internet reachable? before continue
for i in {1..15}; do ping -c1 www.google.com &> /dev/null && break; done

# update
DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null

# install latest version
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq prometheus jq


# install manually latest version?
# https://docs.github.com/en/rest/releases/releases#get-the-latest-release
# URL_PROMETHEUS_LATEST=$(curl  -sS -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/prometheus/prometheus/releases/latest | jq '.["assets"][] | select( ."name" | endswith("linux-amd64.tar.gz") ) | .["browser_download_url"]' | tr -d '"')
# curl -sSLO $URL_PROMETHEUS_LATEST
# tar -xzf prometheus*


# example configuration https://github.com/prometheus/prometheus/blob/release-2.35/config/testdata/conf.good.yml
tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  external_labels:
      monitor: 'example'

alerting:
  alertmanagers:
  - static_configs:
    - targets: ['localhost:9093']

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    scrape_timeout: 5s
    static_configs:
      - targets: ['localhost:9090']

  - job_name: node
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'ec2'
    ec2_sd_configs:
      - region: eu-north-1
        port: 9100

  - job_name: 'nomad_metrics'
    consul_sd_configs:
      - server: '127.0.0.1:8500'
        services: ['nomad-client', 'nomad']

    relabel_configs:
      - source_labels: ['__meta_consul_tags']
        regex: '(.*)http(.*)'
        action: keep

    scrape_interval: 5s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
EOF

# reload
systemctl restart prometheus