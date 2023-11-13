terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
  }
  backend "s3" {
    bucket         = "dos14-tf-state"
    key            = "bpzb/prd/aws/state.tfstate"
    dynamodb_table = "tf_state_bpzb"
    region         = "eu-central-1"
  }
}

provider "aws" {
  region = local.aws_region
}

module "vpcs" {
  source               = "../../../modules/aws/vpc/"
  for_each             = local.vpcs
  name                 = each.value.name
  cidr_block           = each.value.cidr_block
  route_cidr           = each.value.route_cidr
  route_nat_gw         = each.value.route_nat_gw
  enable_dns_hostnames = each.value.enable_dns_hostnames
  subnets_public       = each.value.subnets_public
  subnets_private      = each.value.subnets_private
  internet_gw_name     = each.value.internet_gw_name
  nat_gws              = each.value.nat_gws
}

module "alb" {
  for_each                  = local.albs
  alb_vpc_id                = module.vpcs[each.value.vpc_name].vpc_id
  alb_vpc_name              = each.value.vpc_name
  alb_vpc_public_subnet_ids = module.vpcs[each.value.vpc_name].vpc_public_subnet_ids

  # ALB
  source                 = "../../../modules/aws/alb/"
  alb_name               = each.value.alb_name
  alb_internal           = each.value.alb_internal
  alb_load_balancer_type = each.value.alb_load_balancer_type
  alb_ip_address_type    = each.value.alb_ip_address_type
  # SG
  sg_alb_name          = each.value.sg_alb_name
  sg_alb_description   = each.value.sg_alb_description
  sg_alb_rules_ingress = each.value.sg_alb_rules_ingress
  sg_alb_rules_egress  = each.value.sg_alb_rules_egress
  # TGs
  tgs_alb    = each.value.tgs_alb
  tg_lb_type = each.value.tg_lb_type
  # listener http
  alb_listener_80 = each.value.alb_listener_80
}

module "alb_listener_https" {
  # ALB HTTPS submodule
  source   = "../../../modules/aws/alb/alb_listener_https"
  for_each = local.albs
  # from ALB
  alb_arn = module.alb[each.value.vpc_name].lb_arn
  alb_tg  = module.alb[each.value.vpc_name].lb_tg
  # from route53
  alb_route53_certificate_arn = module.route53[each.value.vpc_name].certificate_arn
  # listener https
  alb_listener_443 = each.value.alb_listener_443
  # listener https rules
  alb_rules = each.value.alb_rules
}

module "route53" {
  source   = "../../../modules/aws/route53/"
  for_each = local.routes53
  # zone
  zone_name = each.value.dns_name
  # records
  records = each.value.records
  # certificate
  cert_domain_name       = each.value.domain_name
  cert_validation_method = each.value.validation_method
}

module "asg" {
  source   = "../../../modules/aws/asg/"
  for_each = local.asgs
  vpc_name = each.value.vpc_name
  # outputs
  vpc_id = module.vpcs[each.value.vpc_name].vpc_id
  # secure groups
  sgs = each.value.sgs
  # image data
  data_ubuntu = each.value.data_ubuntu
  # launch tamplates
  app_lts = each.value.app_lts
  # asgs
  app_asgs = each.value.app_asgs

}
