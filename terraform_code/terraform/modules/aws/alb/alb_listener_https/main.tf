resource "aws_lb_listener" "https" {
  load_balancer_arn = var.alb_arn
  port              = var.alb_listener_443["port"]
  protocol          = var.alb_listener_443["protocol"]
  ssl_policy        = var.alb_listener_443["ssl_policy"]
  certificate_arn   = var.alb_route53_certificate_arn

  default_action {
    type             = var.alb_listener_443["action_type"]
    target_group_arn = var.alb_tg["account"].arn
  }
}

resource "aws_lb_listener_rule" "bpzb-tf" {
  count        = length(var.alb_rules)
  listener_arn = aws_lb_listener.https.arn
  priority     = var.alb_rules[count.index].priority

  action {
    type             = var.alb_rules[count.index].type
    target_group_arn = var.alb_tg[var.alb_rules[count.index].name].arn
  }

  condition {
    path_pattern {
      values = var.alb_rules[count.index].path_values
    }
  }
}

