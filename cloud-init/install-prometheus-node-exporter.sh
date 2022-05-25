#!/usr/bin/env bash

# internet reachable? before continue
until ping4 -c1 archive.ubuntu.com &>/dev/null; do sleep 1; done

# update
apt-get update -qq >/dev/null

# install latest version
apt-get install -y -qq prometheus-node-exporter