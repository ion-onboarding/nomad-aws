#!/usr/bin/env bash

# internet reachable? before continue
for i in {1..15}; do ping -c1 www.google.com &> /dev/null && break; done

# install manually latest version? https://github.com/grafana/loki/releases
# https://grafana.com/docs/loki/latest/installation/

# get loki URL from using github release API
URL_LOKI_LATEST=$(curl  -sS -H "Accept: application/vnd.github.v3+json"   https://api.github.com/repos/grafana/loki/releases/latest | jq '.["assets"][] | select( ."name" | startswith("loki-linux-amd64.zip")) | .["browser_download_url"]' | tr -d '"')

# download loki binary
curl -sSLO $URL_LOKI_LATEST

# extract loki
which unzip || apt-get install -y unzip
unzip loki-linux-amd64.zip

# make binary executable
chmod a+x loki-linux-amd64

# mv to binaries location
mv loki-linux-amd64 /usr/bin