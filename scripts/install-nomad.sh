#!/usr/bin/env bash

# internet reachable? before continue
for i in {1..15}; do ping -c1 www.google.com &> /dev/null && break; done

# update
apt-get update -qq >/dev/null

# install latest version
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nomad
