#!/usr/bin/env bash

# internet reachable? before continue
for i in {1..15}; do ping -c1 www.google.com &> /dev/null && break; done

# install from repository [OSS]
# https://grafana.com/docs/grafana/latest/installation/debian/#install-from-apt-repository

apt-get install -y apt-transport-https
apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -

# Add this repository for stable releases:
echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list

# update, install
apt-get update -qq >/dev/null
apt-get install -y -qq grafana
