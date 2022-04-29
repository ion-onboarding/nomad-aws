## Application Load Balancer
resource "aws_lb" "alb_nomad" {
  name_prefix        = "nomad-" # 6 character length
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = aws_subnet.public.*.id
  idle_timeout       = 60
  ip_address_type    = "dualstack"

  tags = merge(
    { "Name" = "${var.main_project_tag}-alb-nomad" },
    { "Project" = var.main_project_tag }
  )
}

## Target Group
resource "aws_lb_target_group" "alb_targets_nomad" {
  name_prefix          = "nomad"
  port                 = 4646
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

## Default HTTP listener
resource "aws_lb_listener" "alb_http_nomad" {
  load_balancer_arn = aws_lb.alb_nomad.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_targets_nomad.arn
  }
}

## Target Group Attachment
resource "aws_lb_target_group_attachment" "nomad" {
  target_group_arn = aws_lb_target_group.alb_targets_nomad.arn
  target_id        = aws_instance.nomad.id
  port             = 4646
}