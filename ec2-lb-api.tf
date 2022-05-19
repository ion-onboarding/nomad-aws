## Load Balancer
resource "aws_lb" "alb_api" {
  name_prefix        = "api-" # 6 character length
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = aws_subnet.public.*.id
  idle_timeout       = 60
  ip_address_type    = "dualstack"

  tags = merge(
    { "Name" = "${var.main_project_tag}-alb" },
    { "Project" = var.main_project_tag }
  )
}

## Listener
resource "aws_lb_listener" "alb_consul" {
  load_balancer_arn = aws_lb.alb_api.arn
  port              = 8500 # consul
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_targets_consul.arn
  }
}

resource "aws_lb_listener" "alb_nomad" {
  load_balancer_arn = aws_lb.alb_api.arn
  port              = 4646 # nomad
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_targets_nomad.arn
  }
}

resource "aws_lb_listener" "alb_vault" {
  load_balancer_arn = aws_lb.alb_api.arn
  port              = 8200 # vault
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_targets_vault.arn
  }
}

resource "aws_lb_listener" "alb_traefik" {
  load_balancer_arn = aws_lb.alb_api.arn
  port              = 8080 # traefik dashboard
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_targets_traefik.arn
  }
}

resource "aws_lb_listener" "alb_traefik_ap" {
  load_balancer_arn = aws_lb.alb_api.arn
  port              = 80 # traefik apps
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_targets_traefik_app.arn
  }
}

resource "aws_lb_listener" "alb_prometheus" {
  load_balancer_arn = aws_lb.alb_api.arn
  port              = 9090 # prometheus
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_targets_prometheus.arn
  }
}

resource "aws_lb_listener" "alb_grafana" {
  load_balancer_arn = aws_lb.alb_api.arn
  port              = 3000 # grafana
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_targets_prometheus.arn
  }
}

## Target Group
resource "aws_lb_target_group" "alb_targets_consul" {
  name_prefix          = "csul-"
  port                 = 8500 # consul
  protocol             = "HTTP"
  vpc_id               = aws_vpc.vpc.id
  deregistration_delay = 30
  target_type          = "instance"

  # https://www.consul.io/api-docs/health
  health_check {
    enabled             = true
    interval            = 10
    path                = "/v1/status/leader" // the consul API health port?
    protocol            = "HTTP"              // switch to HTTPS?
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = merge(
    { "Name" = "${var.main_project_tag}-tg-consul" },
    { "Project" = var.main_project_tag }
  )
}

resource "aws_lb_target_group" "alb_targets_nomad" {
  name_prefix          = "nomd-"
  port                 = 4646 # nomad
  protocol             = "HTTP"
  vpc_id               = aws_vpc.vpc.id
  deregistration_delay = 30
  target_type          = "instance"

  # https://www.nomadproject.io/api-docs/status
  health_check {
    enabled             = true
    interval            = 10
    path                = "/v1/status/leader" // the nomad API health port?
    protocol            = "HTTP"              // switch to HTTPS?
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = merge(
    { "Name" = "${var.main_project_tag}-tg-nomad" },
    { "Project" = var.main_project_tag }
  )
}

resource "aws_lb_target_group" "alb_targets_vault" {
  name_prefix          = "vault-"
  port                 = 8200 # vault
  protocol             = "HTTP"
  vpc_id               = aws_vpc.vpc.id
  deregistration_delay = 30
  target_type          = "instance"

  # https://www.vaultproject.io/api-docs/system/leader
  health_check {
    enabled             = true
    interval            = 10
    path                = "/v1/sys/leader"    // the API health port?
    protocol            = "HTTP"              // switch to HTTPS?
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = merge(
    { "Name" = "${var.main_project_tag}-tg-vault" },
    { "Project" = var.main_project_tag }
  )
}

resource "aws_lb_target_group" "alb_targets_traefik" {
  name_prefix          = "tfik-"
  port                 = 8080 # traefik dashboard
  protocol             = "HTTP"
  vpc_id               = aws_vpc.vpc.id
  deregistration_delay = 30
  target_type          = "instance"

  # https://www.vaultproject.io/api-docs/system/leader
  # health_check {
  #   enabled             = true
  #   interval            = 10
  #   path                = "/"    // the API health port?
  #   protocol            = "HTTP"              // switch to HTTPS?
  #   timeout             = 5
  #   healthy_threshold   = 3
  #   unhealthy_threshold = 3
  #   matcher             = "200"
  # }

  tags = merge(
    { "Name" = "${var.main_project_tag}-tg-traefik" },
    { "Project" = var.main_project_tag }
  )
}

resource "aws_lb_target_group" "alb_targets_traefik_app" {
  name_prefix          = "tfapp-"
  port                 = 80 # traefik apps
  protocol             = "HTTP"
  vpc_id               = aws_vpc.vpc.id
  deregistration_delay = 30
  target_type          = "instance"

  # https://www.vaultproject.io/api-docs/system/leader
  # health_check {
  #   enabled             = true
  #   interval            = 10
  #   path                = "/v1/sys/leader"    // the API health port?
  #   protocol            = "HTTP"              // switch to HTTPS?
  #   timeout             = 5
  #   healthy_threshold   = 3
  #   unhealthy_threshold = 3
  #   matcher             = "200"
  # }

  tags = merge(
    { "Name" = "${var.main_project_tag}-tg-traefik-app" },
    { "Project" = var.main_project_tag }
  )
}

resource "aws_lb_target_group" "alb_targets_prometheus" {
  name_prefix          = "prom-"
  port                 = 9090 # prometheus
  protocol             = "HTTP"
  vpc_id               = aws_vpc.vpc.id
  deregistration_delay = 30
  target_type          = "instance"

  # # https://www.nomadproject.io/api-docs/status
  # health_check {
  #   enabled             = true
  #   interval            = 10
  #   path                = "/" // the nomad API health port?
  #   protocol            = "HTTP"              // switch to HTTPS?
  #   timeout             = 5
  #   healthy_threshold   = 3
  #   unhealthy_threshold = 3
  #   matcher             = "200"
  # }

  tags = merge(
    { "Name" = "${var.main_project_tag}-tg-prometheus" },
    { "Project" = var.main_project_tag }
  )
}

# resource "aws_lb_target_group" "alb_targets_grafana" {
#   name_prefix          = "graf-"
#   port                 = 3000 # grafana
#   protocol             = "HTTP"
#   vpc_id               = aws_vpc.vpc.id
#   deregistration_delay = 30
#   target_type          = "instance"

#   # # https://www.nomadproject.io/api-docs/status
#   # health_check {
#   #   enabled             = true
#   #   interval            = 10
#   #   path                = "/" // the nomad API health port?
#   #   protocol            = "HTTP"              // switch to HTTPS?
#   #   timeout             = 5
#   #   healthy_threshold   = 3
#   #   unhealthy_threshold = 3
#   #   matcher             = "200"
#   # }

#   tags = merge(
#     { "Name" = "${var.main_project_tag}-tg-grafana" },
#     { "Project" = var.main_project_tag }
#   )
# }

## Target Group Attachment
resource "aws_lb_target_group_attachment" "consul" {
  count            = var.consul_instances_count
  target_group_arn = aws_lb_target_group.alb_targets_consul.arn
  target_id        = aws_instance.consul[count.index].id
  port             = 8500
}

resource "aws_lb_target_group_attachment" "nomad" {
  count            = var.nomad_instances_count
  target_group_arn = aws_lb_target_group.alb_targets_nomad.arn
  target_id        = aws_instance.nomad[count.index].id
  port             = 4646
}

resource "aws_lb_target_group_attachment" "vault" {
  count            = var.vault_instances_count
  target_group_arn = aws_lb_target_group.alb_targets_vault.arn
  target_id        = aws_instance.vault[count.index].id
  port             = 8200
}

resource "aws_lb_target_group_attachment" "traefik" {
  count            = 1
  target_group_arn = aws_lb_target_group.alb_targets_traefik.arn
  target_id        = aws_instance.traefik[count.index].id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "traefik_app" {
  count            = 1
  target_group_arn = aws_lb_target_group.alb_targets_traefik_app.arn
  target_id        = aws_instance.traefik[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "prometheus" {
  count            = 1
  target_group_arn = aws_lb_target_group.alb_targets_prometheus.arn
  target_id        = aws_instance.prometheus[count.index].id
  port             = 9090
}

# resource "aws_lb_target_group_attachment" "grafana" {
#   count            = 1
#   target_group_arn = aws_lb_target_group.alb_targets_prometheus.arn
#   target_id        = aws_instance.prometheus[count.index].id
#   port             = 3000
# }

