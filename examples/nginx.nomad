job "nginx" {
  datacenters = ["dc1"]

  group "nginx" {
    count = 1

    service {
        name = "nginx"
        port = "http"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.traefik-to-nginx.rule=Path(`/blue`)"
        ]
    }

    network {
      port "http" {
        static = 3000
      }
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx"
        ports = ["http"]

        volumes = [
          "local/usr/share/nginx/html:/usr/share/nginx/html",
          "local/etc/nginx/conf.d:/etc/nginx/conf.d",
        ]
      }

      template {
        data = <<EOF
# https://www.nginx.com/resources/wiki/start/topics/examples/full/
    server {
        listen       3000;
        server_name  _;
        location /blue {
            try_files /index.html $uri $uri/ =404;
            root /usr/share/nginx/html;
        }
        location /green {
            try_files /index.html $uri $uri/ =404;
            root /usr/share/nginx/html;
        }
  }
EOF

        destination   = "local/etc/nginx/conf.d/site.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>nomad</title>
</head>
<body>
    <h1 style="text-align:center;">Hello World!</h1>
    <script>
        if (window.location.pathname == "/blue") { document.body.style.backgroundColor = "LightSkyBlue"}
        else if (window.location.pathname == "/green") { document.body.style.backgroundColor = "PaleGreen"}
    </script>
</body>
</html>
EOF

        destination   = "local/usr/share/nginx/html/index.html"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}