# nomad bootstrap acl

### Steps: Machines running nomad in sever mode

- check if NOMAD_ADDR points to the correct cluster
```
echo $NOMAD_ADDR
```

- create an anonymous policy (already created __anonymous.policy.hcl__ in this directory)
```
namespace "*" {
  policy       = "write"
  capabilities = ["alloc-node-exec"]
}

agent {
  policy = "write"
}

operator {
  policy = "write"
}

quota {
  policy = "write"
}

node {
  policy = "write"
}

host_volume "*" {
  policy = "write"
}
```

- enable acl
    - on all nomad servers (not clients)
    - SSH needed? check variable __bastion_enable__ `ec2-variables.tf`
    - on machine edit using vim or nano
```
sudo vim /etc/nomad.d/nomad.hcl
```
- append following stanza in `/etc/nomad.d/nomad.hcl` on all nomad severs (not clients yet)

```
acl {
  enabled = true
}
```

- restart nomad process (not the machine)
    - if more than one machine, restart nomad process on each
    - do not restart nomad process on all servers at the same time
```
sudo systemctl restart nomad
```

- exit SSH, logout from SSH servers
    - return back to your computer (exit SSH to servers)

- bootstrap
    - fetch the management token
    - also known as root or admin token
```
nomad acl bootstrap 2>&1 | tee bootstrap.token
```

- ACL feature is enabled now (but `NOMAD_TOKEN` not set as environment variable)
    - if we query the servers an expected error is returned
        - `Error querying servers: Unexpected response code: 403 (Permission denied)`
    - that is because we need a secret token
```
nomad sever members
```

- copy __Secret ID__ into environment variable __NOMAD_ADDR__
```
export NOMAD_TOKEN="<Secret ID>"
```

- verify that token used is correct
```
nomad server members
```

- apply the anonymous policy `nomad acl policy apply [options] <name> <path>`
```
nomad acl policy apply -description "Anonymous policy (full access)" anonymous anonymous.policy.hcl
```

### Steps: Machines running nomad in client mode
- enable acl
    - SSH needed? check variable __bastion_enable__  in file `ec2-variables.tf`
    - on machine edit using vim or nano
```
sudo vim /etc/nomad.d/nomad.hcl
```

- append following stanza in `/etc/nomad.d/nomad.hcl` on all nomad severs (not clients yet)

```
acl {
  enabled = true
}
```

- restart nomad process (not the machine)
    - if more than one machine, restart nomad process on each
    - do not restart nomad process on all servers at the same time
```
sudo systemctl restart nomad
```