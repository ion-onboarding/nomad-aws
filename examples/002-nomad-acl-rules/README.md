# Tokens

- set a token in an env variable
```
export NOMAD_TOKEN=<token>
```

- unset a token
```
unset NOMAD_TOKEN
```

- create a token
```
nomad acl token create -name="monitor events" policy="anonymous"
```

- list tokens (if needed use management token)
```
nomad acl token list
```

- check current token used
```
nomad acl token self
```
```
echo $NOMAD_TOKEN
```

- update token
```
nomad acl token update -name "token used to monitor events (NOC)" <Token_Accessor_ID>
```

- create a second management token
```
nomad acl token create -name="New Management Token" -type="management"
```

- example of management token
```
Accessor ID  = <token-random-ID1, token omitted in this output>
Secret ID    = <random-ID2, token omitted in this output>
Name         = Bootstrap Token
Type         = management
Global       = true
Policies     = n/a
Create Time  = 2022-05-24 21:31:19.100339564 +0000 UTC
Create Index = 41
Modify Index = 41
```


# ACL Policy rules
- read
    - all resources are to be read only
- write
    - allow read and write
- deny
    - not allowed
    - if one token two policies referencing same resource
        - deny takes precedence
- list


## Example
- read only policy (default is `deny`, we override that with `read`)
```
namespace "default" {
    policy = "read"
}

agent {
    policy = "read"
}

node {
    policy = "read"
}

quota {
    policy = "read"
}
```

Nomad takes care of application runtime lifecycle. Applications are deployed through jobs.

What can you do with a job?
- list-jobs
- read-job
- submit-job
- dispatch-job (parameterized)
- read-logs
- alloc-exec
- alloc-node-exec
- alloc-lifecycle

Policy actions related to jobs
- read
    - list-jobs
    - read-job
    - csi-read-volume
    - list-scaling-policies
    - read-scaling-policy
    - read-job-scaling
- write
    - list-jobs
    - read-job
    - submit-job
    - dispatch-job
    - read-logs
    - read-fs
    - alloc-exec
    - alloc-lifecycle
    - csi-write-volume
    - csi-mount-volume
    - list-scaling-policies
    - read-scaling-policy
    - scale-job
- scale
    - list-scaling-policies
    - read-scaling-policies
    - read-job-scaling
    - scale-job
- deny
    - denies access


## Example:
- allow reading and submitting jobs (view of logs is implicitly denied)
- bellow examples do the same thing
```
namespace "default" {
    policy       = "read"
    capabilities = ["submit-job"]
}
```

```
namespace "default" {
    capabilities = ["submit-job", "list-jobs", "read-job"]
}
```

## Resources not in a namespace
- agent
    - agent allowed to join or leave cluster
- operator
    -  collect operator bundle to be provided to support
- quota
    - interact with resource quotas
- host_volume
    - volume commands
- plugin
    - allow using docker or lxd plugin


# Example: create a policy for developers
Developer policy
- submit job
- inspect a job
- list running jobs
- dispatch jobs
- read-log

developer.policy.acl (created here in this directory)
```
namespace "default" {
    policy       = "read"
    capabilities = ["submit-job", "dispatch-job", "read-logs"]
}
```

- create the policy
```
nomad acl policy apply -description="policy for developers" developer developer.policy.hcl
```

- verify policy created
```
nomad acl policy list
```

cat super-engineer.token
```
nomad acl token create -name="super-engineer developer" -policy=developer - type=client 2>&1 | tee super-engineer.token
```