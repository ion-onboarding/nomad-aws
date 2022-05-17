#!/usr/bin/env bash

# internet reachable? before continue
for i in {1..15}; do ping -c1 www.google.com &> /dev/null && break; done

# install from repository [OSS]
# https://grafana.com/docs/grafana/latest/installation/debian/#install-from-apt-repository

DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https
DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common wget
DEBIAN_FRONTEND=noninteractive wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -

# Add this repository for stable releases:
echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list

# update, install
DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq grafana

# start grafana
systemctl enable grafana-server
systemctl start grafana-server
