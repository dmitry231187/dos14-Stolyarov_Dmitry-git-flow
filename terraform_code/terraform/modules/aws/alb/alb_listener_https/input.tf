
variable "alb_arn" {
  description = "The ARN of the load balancer (matches id)"
}

variable "alb_tg" {
  description = "alb target group"
}

variable "alb_listener_443" {
  description = "Load Balancer Listener https port443 variables"
  type = object(
    {
      port        = number
      protocol    = string
      action_type = string
      ssl_policy  = string
    }
  )
}

variable "alb_route53_certificate_arn" {
  description = "sertificate arn from route53 module"
}

variable "alb_rules" {
  description = "alb listeners rules"
  type = list(
    object(
      {
        name        = string
        priority    = number
        type        = string
        path_values = set(string)
      }
    )
  )
}

