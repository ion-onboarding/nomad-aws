#!/usr/bin/env bash

# internet reachable? before continue
until ping4 -c1 github.com ; do sleep 1; done

# install traefik - https://github.com/traefik/traefik/releases
# curl --silent -LO https://github.com/traefik/traefik/releases/download/v2.6.3/traefik_v2.6.3_linux_amd64.tar.gz
# tar -xzf traefik_v2.6.3_linux_amd64.tar.gz traefik
# rm traefik_v2.6.3_linux_amd64.tar.gz

# install manually latest version?
# https://docs.github.com/en/rest/releases/releases#get-the-latest-release
apt-get install -y jq
URL_TRAEFIK_LATEST=$(curl  -sS -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/traefik/traefik/releases/latest | jq '.["assets"][] | select( ."name" | endswith("linux_amd64.tar.gz") ) | .["browser_download_url"]' | tr -d '"')
curl -sSLO $URL_TRAEFIK_LATEST
tar -xzf traefik* traefik


chown root:root traefik
chmod 755 traefik
cp traefik /usr/local/bin

useradd --system --home /etc/consul.d --shell /bin/false traefik

# allow traefik to bind to low level ports
setcap 'cap_net_bind_service=+ep' /usr/local/bin/traefik

# configuration location
mkdir -p /etc/traefik/acme
sudo chown -R root:root /etc/traefik
sudo chown -R traefik:traefik /etc/traefik/acme

touch /etc/traefik/traefik.yaml
chown root:root /etc/traefik/traefik.yaml
chmod 644 /etc/traefik/traefik.yaml

tee /etc/systemd/system/traefik.service > /dev/null <<EOT
[Unit]
Description=traefik proxy
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Restart=on-abnormal

## User and group the process will run as.
User=traefik
Group=traefik

## Always set "-root" to something safe in case it gets forgotten in the traefikfile.
ExecStart=/usr/local/bin/traefik --configfile=/etc/traefik/traefik.yaml

## Limit the number of file descriptors; see 'man systemd.exec' for more limit settings.
LimitNOFILE=1048576

## Use private /tmp and /var/tmp, which are discarded after traefik stops.
PrivateTmp=true

## Use a minimal /dev (May bring additional security if switched to 'true', but it may not work on Raspberry Pi's or other devices, so it has been disabled in this dist.)
PrivateDevices=false

## Hide /home, /root, and /run/user. Nobody will steal your SSH-keys.
ProtectHome=true

## Make /usr, /boot, /etc and possibly some more folders read-only.
ProtectSystem=full

## … except /etc/ssl/traefik, because we want Letsencrypt-certificates there.
##   This merely retains r/w access rights, it does not add any new. Must still be writable on the host!
ReadWriteDirectories=/etc/traefik/acme

## The following additional security directives only work with systemd v229 or later.
## They further restrict privileges that can be gained by traefik. Uncomment if you like.
## Note that you may have to add capabilities required by any plugins in use.
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOT

sudo chown root:root /etc/systemd/system/traefik.service
sudo chmod 644 /etc/systemd/system/traefik.service

# logging
mkdir -p /var/log/traefik/
chown traefik:traefik /var/log/traefik/
chmod 755 /var/log/traefik/