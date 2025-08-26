resource "aws_security_group" "main" {
  name        = "${var.service_name}-sg-${var.name}-alb"
  description = var.sg_description
  vpc_id      = var.vpc_id

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      cidr_blocks = egress.value.cidr_blocks
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
    }
  }

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      cidr_blocks = ingress.value.cidr_blocks
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
    }
  }

  tags = {
    Name = "${var.service_name}-sg-${var.name}-alb"
  }
}

resource "aws_lb" "main" {
  name               = "${var.service_name}-alb-${var.name}"
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.main.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = var.access_logs != null ? [var.access_logs] : []
    content {
      bucket  = access_logs.value.bucket
      prefix  = access_logs.value.prefix
      enabled = access_logs.value.enabled
    }
  }

  tags = merge(
    var.tags,
    { Name = "${var.service_name}-alb-${var.name}" }
  )
}

resource "aws_lb_target_group" "main" {
  ip_address_type               = var.ip_address_type
  load_balancing_algorithm_type = var.load_balancing_algorithm_type
  name                          = "${var.service_name}-tg-${var.name}"
  port                          = var.target_group_port
  protocol                      = var.target_group_protocol
  protocol_version              = var.protocol_version
  target_type                   = var.target_type
  vpc_id                        = var.vpc_id

  dynamic "health_check" {
    for_each = var.health_check != null ? [var.health_check] : []
    content {
      enabled             = health_check.value.enabled
      path                = health_check.value.path
      port                = health_check.value.port
      protocol            = health_check.value.protocol
      matcher             = try(health_check.value.matcher, 200)
      interval            = try(health_check.value.interval, 30)
      timeout             = try(health_check.value.timeout, 5)
      healthy_threshold   = try(health_check.value.healthy_threshold, 3)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, 3)
    }
  }
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  ssl_policy        = var.ssl_policy
  default_action {
    target_group_arn = aws_lb_target_group.main.arn
    type             = "forward"
  }
  certificate_arn = var.certificate_arn
}

resource "aws_route53_record" "main" {
  count = var.domain_name != null && var.zone_id != null ? 1 : 0

  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    evaluate_target_health = true
    zone_id                = aws_lb.main.zone_id
  }
}
