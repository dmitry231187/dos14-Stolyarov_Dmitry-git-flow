resource "aws_security_group" "jh" {
  name        = "${var.sgs.jumphost.name}-${var.vpc_name}"
  description = var.sgs.jumphost.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sgs.jumphost.rules.ingress
    content {
      description      = ingress.value.description
      from_port        = ingress.value.port
      to_port          = ingress.value.port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidrs_ipv4
      ipv6_cidr_blocks = ingress.value.cidrs_ipv6
    }
  }

  dynamic "egress" {
    for_each = var.sgs.jumphost.rules.egress
    content {
      description      = egress.value.description
      from_port        = egress.value.port
      to_port          = egress.value.port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidrs_ipv4
      ipv6_cidr_blocks = egress.value.cidrs_ipv6
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "app" {
  name        = "${var.sgs.app.name}-${var.vpc_name}"
  description = var.sgs.app.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sgs.app.rules.ingress
    content {
      description     = ingress.value.description
      from_port       = ingress.value.port
      to_port         = ingress.value.port
      protocol        = ingress.value.protocol
      security_groups = ingress.value.jh_key ? [aws_security_group.jh.id] : ingress.value.security_groups
    }
  }

  dynamic "egress" {
    for_each = var.sgs.app.rules.egress
    content {
      description = egress.value.description
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidrs_ipv4
    }
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_security_group.jh]
}


data "aws_ami" "ubuntu" {
  most_recent = var.data_ubuntu.most_recent
  dynamic "filter" {
    for_each = var.data_ubuntu.filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
  owners = var.data_ubuntu.owners
}

resource "aws_launch_template" "app" {
  for_each               = var.app_lts
  name                   = each.value.name
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = each.value.instance_type
  key_name               = each.value.key_name
  vpc_security_group_ids = each.value.name == "jump_host" ? [aws_security_group.jh.id] : [aws_security_group.app.id]
  iam_instance_profile {
    name = each.value.iam_instance_profile_name
  }
  lifecycle {
    create_before_destroy = true
  }
  user_data = filebase64(each.value.user_data)
}

resource "aws_autoscaling_group" "bpzb" {
  for_each            = var.app_asgs
  name                = "${each.value.name}-v${aws_launch_template.app[each.value.lt_app_name].latest_version}"
  min_size            = each.value.min_size
  desired_capacity    = each.value.desired_capacity
  max_size            = each.value.max_size
  vpc_zone_identifier = each.value.vpc_zone_identifier
  target_group_arns   = [each.value.target_group_arn]

  launch_template {
    id      = aws_launch_template.app[each.value.lt_app_name].id
    version = aws_launch_template.app[each.value.lt_app_name].latest_version
  }

  tag {
    key                 = each.value.tag_key
    value               = "${each.value.name}-lt_v${aws_launch_template.app[each.value.lt_app_name].latest_version}"
    propagate_at_launch = each.value.tag_propagate_at_launch
  }

  lifecycle {
    create_before_destroy = true
  }
}
