variable "name" {
  description = "vpc name"
  type        = string
}

variable "cidr_block" {
  description = "vpc cidr block"
  type        = string
}

variable "route_nat_gw" {
  description = "nat for route table for private subnets"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "enable/disable DNS hostnames in the VPC"
  type        = bool
}

variable "route_cidr" {
  description = "route cidr block"
  type        = string
}

variable "nat_gws" {
  description = "nat gateways"
  type = map(
    object(
      {
        eip_name            = string
        name                = string
        subnet_to_place_nat = string
      }
    )
  )
}

variable "internet_gw_name" {
  description = "vpc internet gateway name"
  type        = string
}

variable "subnets_public" {
  description = "vpc public subnets"
  type = map(
    object(
      {
        cidr                = string
        name                = string
        availability_zone   = string
        public_ip_on_launch = bool
      }
    )
  )
}

variable "subnets_private" {
  description = "vpc private subnets"
  type = map(
    object(
      {
        cidr              = string
        name              = string
        availability_zone = string
      }
    )
  )
}
