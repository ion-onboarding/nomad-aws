# nomad-aws
Nomad cluster following [nomad architecture reference](https://learn.hashicorp.com/tutorials/nomad/production-reference-architecture-vm-with-consul?in=nomad/enterprise)

## Diagram
![](./diagram/diagram.png)

## How to use this repo
- Clone this repo
```
git clone https://github.com/ion-onboarding/nomad-aws.git
```

- change directory
```
cd nomad-aws
```

## Create infrastructure
- initialize working directory
```
terraform init
```

- plan, to see what resources will be create
```
terraform plan
```

- create resources
```
terraform apply
```

## How to connect?
- use terraform output to get:
  - SSH details
  - URL to access GUI
  - ENV variables
```
terraform output
```

## Destroy infrastructure
- destroy resources
```
terraform destroy
```

# Server details

## Consul
- members
```
consul members
```

- raft peers
```
consul operator raft list-peers
```

## Vault
- GUI user password
```
username: admin
password: admin
```
- status
```
vault status
```

- login on the CLI
```
vault login -method=userpass username=admin password=admin
```

## Nomad
- servers
```
nomad server members
```

- nodes
```
nomad node status
```

- raft peers
```
nomad operator raft list-peers
```

## Nomad workloads
- run a job, which is a web server
```
nomad job run examples/web-traefik.nomad
```

- output URL of LoadBalancer
```
terraform output URL_LoadBalancer
```

- access the web server
```
http://<URL_LoadBalancer>/web
```
