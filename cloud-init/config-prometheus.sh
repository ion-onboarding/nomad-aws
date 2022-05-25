#!/usr/bin/env bash

# prometheus installed before configuration
while [ ! -f /usr/bin/prometheus ]; do sleep 1; done

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

  # - job_name: node
  #   static_configs:
  #     - targets: ['localhost:9100']

  - job_name: 'ec2'
    ec2_sd_configs:
      - region: '${provider_region}'
        port: 9100
    scrape_interval: 5s
    
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