locals {
  asgs = {
    bpzb-tf = {
      vpc_name = "bpzb-tf"
      sgs = {
        jumphost = {
          name        = "SG_jumphost"
          description = "Allow ssh inbound traffic to jumphost"
          rules = {
            ingress = [
              {
                port        = 22
                protocol    = "tcp"
                description = "ssh from internet"
                cidrs_ipv4  = ["0.0.0.0/0"]
                cidrs_ipv6  = ["::/0"]
              }
            ]
            egress = [
              {
                port        = 0
                protocol    = "-1"
                description = "Allow all"
                cidrs_ipv4  = ["0.0.0.0/0"]
                cidrs_ipv6  = ["::/0"]
              }
            ]
          }
        }
        app = {
          name        = "SG_app"
          description = "Allow http from alb and all from jumphost inbound traffic to apps"
          rules = {
            ingress = [
              { #jh
                jh_key      = true
                port        = 0
                protocol    = "-1"
                description = "all from jumphost"
              },
              { #alb
                port            = 80
                protocol        = "tcp"
                description     = "http form ALB"
                security_groups = [module.alb["bpzb-tf"].lb_sg_id]
              }
            ]
            egress = [
              {
                port        = 0
                protocol    = "-1"
                description = "Allow all"
                cidrs_ipv4  = ["0.0.0.0/0"]
              }
            ]
          }
        }
      }
      data_ubuntu = {
        most_recent = true
        owners      = ["099720109477"] # Canonical
        filters = [
          {
            name   = "name"
            values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64*"]
          },
          {
            name   = "virtualization-type"
            values = ["hvm"]
          }
        ]
      }
      app_lts = { #launch app tamplates
        authz = {
          name          = "authz-tf"
          instance_type = "t2.micro"
          key_name      = "bank_rsa"
          user_data     = "./config_files/authz.yaml"
        }
        authn = {
          name          = "authn-tf"
          instance_type = "t2.micro"
          key_name      = "bank_rsa"
          user_data     = "./config_files/authn.yaml"
        }
        bank = {
          name                      = "bank-tf"
          instance_type             = "t2.micro"
          key_name                  = "bank_rsa"
          user_data                 = "./config_files/bank.yaml"
          iam_instance_profile_name = "ec2-s3"
        }
        account = {
          name          = "account-tf"
          instance_type = "t2.micro"
          key_name      = "bank_rsa"
          user_data     = "./config_files/account.yaml"
        }
        jump_host = {
          name          = "jump_host"
          instance_type = "t2.micro"
          key_name      = "bank_rsa"
          user_data     = "./config_files/jh.yaml"
        }
      }
      app_asgs = { # autoscaling gtoups
        authz = {
          name                    = "bpzb-authz-tf"
          min_size                = 2
          max_size                = 3
          desired_capacity        = 2
          vpc_zone_identifier     = module.vpcs["bpzb-tf"].vpc_private_subnet_ids
          lt_app_name             = "authz"
          target_group_arn        = module.alb["bpzb-tf"].lb_tg["authz"].arn
          tag_key                 = "Name"
          tag_propagate_at_launch = true
        }
        authn = {
          name                    = "bpzb-authn-tf"
          min_size                = 2
          max_size                = 3
          desired_capacity        = 2
          vpc_zone_identifier     = module.vpcs["bpzb-tf"].vpc_private_subnet_ids
          lt_app_name             = "authn"
          target_group_arn        = module.alb["bpzb-tf"].lb_tg["authn"].arn
          tag_key                 = "Name"
          tag_propagate_at_launch = true
        }
        bank = {
          name                    = "bpzb-bank-tf"
          min_size                = 2
          max_size                = 3
          desired_capacity        = 2
          vpc_zone_identifier     = module.vpcs["bpzb-tf"].vpc_private_subnet_ids
          lt_app_name             = "bank"
          target_group_arn        = module.alb["bpzb-tf"].lb_tg["bank"].arn
          tag_key                 = "Name"
          tag_propagate_at_launch = true
        }
        account = {
          name                    = "bpzb-account-tf"
          min_size                = 2
          max_size                = 3
          desired_capacity        = 2
          vpc_zone_identifier     = module.vpcs["bpzb-tf"].vpc_private_subnet_ids
          lt_app_name             = "account"
          target_group_arn        = module.alb["bpzb-tf"].lb_tg["account"].arn
          tag_key                 = "Name"
          tag_propagate_at_launch = true
        }
        jh = {
          name                    = "bpzb-jh-tf"
          min_size                = 1
          max_size                = 2
          desired_capacity        = 1
          vpc_zone_identifier     = module.vpcs["bpzb-tf"].vpc_public_subnet_ids
          lt_app_name             = "jump_host"
          tag_key                 = "Name"
          tag_propagate_at_launch = true
        }
      }
    }
  }
}

