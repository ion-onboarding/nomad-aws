#!/usr/bin/env bash

# internet reachable? before continue
for i in {1..15}; do ping -c1 www.google.com &> /dev/null && break; done

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# add ubuntu to docker group
usermod -aG docker ubuntu