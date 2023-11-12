variable "vpc_id" {
  description = "vpc id"
}

variable "vpc_name" {
  description = "vpc name"
}

variable "sgs" {
  description = "rules for security groups"
  type = object(
    {
      jumphost = object(
        {
          name        = string
          description = string
          rules = object(
            {
              ingress = list(
                object(
                  {
                    port        = number
                    protocol    = string
                    description = string
                    cidrs_ipv4  = list(string)
                    cidrs_ipv6  = optional(list(string))
                  }
                )
              )
              egress = list(
                object(
                  {
                    port        = number
                    protocol    = string
                    description = string
                    cidrs_ipv4  = list(string)
                    cidrs_ipv6  = optional(list(string))
                  }
                )
              )
            }
          )
        }
      )
      app = object(
        {
          name        = string
          description = string
          rules = object(
            {
              ingress = list(
                object(
                  {
                    jh_key          = optional(bool, false)
                    port            = number
                    protocol        = string
                    description     = string
                    cidrs_ipv4      = optional(list(string))
                    security_groups = optional(list(string))
                  }
                )
              )
              egress = list(
                object(
                  {
                    port            = number
                    protocol        = string
                    description     = string
                    cidrs_ipv4      = optional(list(string))
                    security_groups = optional(list(string))
                  }
                )
              )
            }
          )
        }
      )
    }
  )
}

variable "data_ubuntu" {
  description = ""
  type = object(
    {
      most_recent = bool
      owners      = list(string)
      filters = list(
        object(
          {
            name   = string
            values = list(string)
          }
        )
      )
    }
  )
}

variable "app_lts" {
  description = "app launch tamplates"
  type = map(
    object(
      {
        name                      = string
        instance_type             = string
        key_name                  = string
        user_data                 = string
        iam_instance_profile_name = optional(string, null)
      }
    )
  )
}

variable "app_asgs" {
  description = "app Auto Scaling groups"
  type = map(
    object(
      {
        name                    = string
        min_size                = number
        max_size                = number
        desired_capacity        = number
        vpc_zone_identifier     = list(string)
        lt_app_name             = string
        target_group_arn        = optional(string, "")
        tag_key                 = string
        tag_propagate_at_launch = bool
      }
    )
  )
}

