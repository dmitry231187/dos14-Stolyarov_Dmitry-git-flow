variable "zone_name" {
  description = "This is the name of the hosted zone"
  type        = string
}

variable "records" {
  description = "map of records for aws route53 A records "
  type = object(
    {
      a_records = list(
        object(
          {
            record_name = string
            record_type = string
            aliases = list(
              object(
                {
                  alb_dns_name  = string
                  alb_zone_id   = string
                  target_health = bool
                }
              )
            )
          }
        )
      )
      cname_validation_record = object(
        {
          record_ttl = number
          overwrite  = bool
        }
      )
      other_records = list(
        object(
          {
            test_record = optional(bool)
            record_name = string
            record_type = string
            record_ttl  = optional(number)
            overwrite   = optional(bool)
            records     = optional(list(string))
          }
        )
      )
    }
  )
}

variable "cert_domain_name" {
  description = "Domain name for which the certificate should be issued"
  type        = string
}

variable "cert_validation_method" {
  description = "Which method to use for validation. DNS or EMAIL are valid"
  type        = string
}

