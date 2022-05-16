## Nomad workloads

### traefik blue-green path
- run the web server job
```
nomad job run examples/nginx.nomad
```

- access the web server
```
http://<URL_LoadBalancer>/blue
```

- modify the job file `./examples/nginx.nomad`
```
Path(`/blue`) modify into Path(`/green`)
```

- run the web server job again
```
nomad job run examples/nginx.nomad
```

- access the web server
```
http://<URL_LoadBalancer>/green
```