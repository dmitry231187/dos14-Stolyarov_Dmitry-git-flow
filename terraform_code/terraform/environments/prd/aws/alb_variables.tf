locals {
  albs = {
    bpzb-tf = {
      vpc_name               = "bpzb-tf"
      alb_name               = "ALB"
      alb_internal           = "false"
      alb_load_balancer_type = "application"
      alb_ip_address_type    = "ipv4" #"dualstack"
      sg_alb_name            = "SG_ALB"
      sg_alb_description     = "Allow 80 and 443 inbound traffic to ALB"
      sg_alb_rules_ingress = {
        ports = [
          {
            port        = 80
            protocol    = "tcp"
            description = "http from internet"
          },
          {
            protocol    = "tcp"
            port        = 443
            description = "https from internet"
          }
        ]
        cidrs_ipv4 = ["0.0.0.0/0"]
        cidrs_ipv6 = ["::/0"]
      }
      sg_alb_rules_egress = {
        ports = [
          {
            port        = 0
            protocol    = "-1"
            description = "Allow all"
          }
        ]
        cidrs_ipv4 = ["0.0.0.0/0"]
        cidrs_ipv6 = ["::/0"]
      }
      #  sg_alb_create_before_destroy = "true" #not usable
      # tg = target group; name = key
      tgs_alb = {
        authz = {
          port     = 80
          protocol = "HTTP"
          path     = "/api/v1/authz/health_check"
          matcher  = 200
        }
        authn = {
          port     = 80
          protocol = "HTTP"
          path     = "/api/v1/authn/health_check"
          matcher  = 200
        }
        bank = {
          port     = 80
          protocol = "HTTP"
          path     = "/api/v1/bank/health_check"
          matcher  = 200
        }
        account = {
          port     = 80
          protocol = "HTTP"
          path     = "/api/v1/account/health_check"
          matcher  = 200
        }
      }
      tg_lb_type = "instance" #"alb"

      alb_listener_80 = {
        port               = 80
        protocol           = "HTTP"
        action_type        = "redirect"
        action_port        = 443
        action_protocol    = "HTTPS"
        action_status_code = "HTTP_301"
      }

      alb_listener_443 = {
        port        = 443
        protocol    = "HTTPS"
        ssl_policy  = "ELBSecurityPolicy-TLS13-1-2-2021-06"
        action_type = "forward"
      }

      alb_rules = [
        {
          name        = "authz"
          priority    = 2
          type        = "forward"
          path_values = ["/api/v1/authz/health_check", "/api/v1/users*", "/api/v1/organisations*", "/api/v1/?*/authz/?*"]
        },
        {
          name        = "authn"
          priority    = 3
          type        = "forward"
          path_values = ["/api/v1/authn/health_check", "/api/v1/identity/validate", "/api/v1/identity/login", "/api/v1/identity"]
        },
        {
          name        = "bank"
          priority    = 4
          type        = "forward"
          path_values = ["/api/v1/bank/health_check", "/api/v1/credits*", "/api/v1/deposits*"]
        },
        {
          name        = "account"
          priority    = 5
          type        = "forward"
          path_values = ["/", ] #["/api/v1/account/*", "/api/v1/account"]
        }
      ]
    }
  }
}

