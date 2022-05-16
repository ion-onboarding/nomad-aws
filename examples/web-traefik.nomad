job "web-traefik" {
  datacenters = ["dc1"]

  group "example" {
    network {
      port "http" {
        static = "5678"
      }
    }
    task "server" {
      driver = "docker"

      service {
        name = "web-traefik"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.myrouter.rule=Path(`/web`)"
        ]

        port = "http"

        meta {
          meta = "for your service"
        }
      }

      config {
        image = "hashicorp/http-echo"
        ports = ["http"]
        args = [
          "-listen",
          ":5678",
          "-text",
          "<h1>hello world</h1>",
        ]
      }
    }
  }
}