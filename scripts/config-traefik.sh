#!/usr/bin/env bash

# traefik, consul installed before configuration
while [ ! -f /usr/local/bin/traefik ]; do sleep 1; done
while [ ! -f /usr/bin/consul ]; do sleep 1; done

PUBLIC_HOSTNAME = $(curl http://169.254.169.254/latest/meta-data/public-hostname)

# traefik static config
tee /etc/traefik/traefik.yaml > /dev/null <<EOF
## STATIC CONFIGURATION
log:
  level: DEBUG
  filePath: "/var/log/traefik/traefik.log"

accessLog:
  filePath: "/var/log/traefik/access.log"

api:
  insecure: true
  dashboard: true # dashboard on port 8080

entryPoints:
  web:
    address: :80
  websecured:
    address: :443

providers:
  consulCatalog:
    prefix: "traefik"
    exposedByDefault: false
    endpoint:
      address: 127.0.0.1:8500
      scheme: "http"
    defaultRule:
      - Host(\`localhost\`) || Host(\`example.com\`) || HostRegexp(\`{subdomain:[a-zA-Z0-9-]+}.{subdomain:[a-zA-Z0-9-]+}.elb.amazonaws.com\`)
EOF

# tee /etc/traefik/provider_consul_catalog.yaml > /dev/null <<EOF
# http:
#   routers:
#     myrouter:
#       entryPoints:
#         - web
#       rule: Host(\`ec2-13-49-57-132.eu-north-1.compute.amazonaws.com\`) || PathPrefix(\`/api\`) || PathPrefix(\`/dashboard\`)
#       service:
#         - myservice
# EOF

start traefik
systemctl enable --now --no-block traefik
