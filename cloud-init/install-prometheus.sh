#!/usr/bin/env bash

# internet reachable? before continue
for i in {1..15}; do ping -c1 www.google.com &> /dev/null && break; done

# update
DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null

# install latest version
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq prometheus


# install manually latest version?
# https://docs.github.com/en/rest/releases/releases#get-the-latest-release
# URL_PROMETHEUS_LATEST=$(curl  -sS -H "Accept: application/vnd.github.v3+json"   https://api.github.com/repos/prometheus/prometheus/releases/latest | jq '.["assets"][] | select( ."name" | endswith("linux-amd64.tar.gz") ) | .["browser_download_url"]' | tr -d '"')
# curl -sSLO $URL_PROMETHEUS_LATEST
# tar -xzf prometheus*