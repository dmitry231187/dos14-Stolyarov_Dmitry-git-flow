variable "alb_vpc_id" {
  description = "vpc id"
}

variable "alb_vpc_public_subnet_ids" {
  description = "vpc public subnet ids"
}

variable "alb_vpc_name" {
  description = "vpc name"
}

variable "alb_name" {
  description = "alb name"
  type        = string
}

variable "alb_internal" {
  description = "internal or not alb"
  type        = bool
}

variable "alb_load_balancer_type" {
  description = "type of load balancer to create"
  type        = string
}

variable "alb_ip_address_type" {
  description = "type of IP addresses used by subnets"
  type        = string
}

variable "sg_alb_name" {
  description = "alb security group name"
  type        = string
}

variable "sg_alb_description" {
  description = "description for alb security group"
  type        = string
}

variable "sg_alb_rules_ingress" {
  description = "ingress rules for alb security group"
  type = object(
    {
      ports = list(
        object(
          {
            port        = number
            protocol    = string
            description = string
          }
        )
      )
      cidrs_ipv4 = list(string)
      cidrs_ipv6 = optional(list(string))
    }
  )
}

variable "sg_alb_rules_egress" {
  description = "egress rules for alb security group"
  type = object(
    {
      ports = list(
        object(
          {
            description = string
            port        = number
            protocol    = string
          }
        )
      )
      cidrs_ipv4 = list(string)
      cidrs_ipv6 = optional(list(string))
    }
  )
}

variable "tgs_alb" {
  description = "alb target groups"
  type = map(
    object(
      {
        port     = number
        protocol = string
        path     = string
        matcher  = number
      }
    )
  )
}

variable "tg_lb_type" {
  description = "type of lb"
  type        = string
}

variable "alb_listener_80" {
  description = "Load Balancer Listener http port80 variables"
  type = object(
    {
      port               = number
      protocol           = string
      action_type        = string
      action_port        = number
      action_protocol    = string
      action_status_code = string
    }
  )
}

