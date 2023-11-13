resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = var.name
  }
}

resource "aws_eip" "eip_nat" {
  for_each = var.nat_gws
  tags = {
    Name = "${each.value.eip_name}-${each.value.subnet_to_place_nat}"
  }
}

resource "aws_route_table" "public" {
  for_each = var.subnets_public
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block = var.route_cidr
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    cidr_block = var.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "route_table_public-tf"
  }

  depends_on = [aws_internet_gateway.gw, aws_vpc.main, aws_subnet.public]
}

resource "aws_route_table" "private" {
  for_each = var.subnets_private
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block     = var.route_cidr
    nat_gateway_id = aws_nat_gateway.nat[var.route_nat_gw].id
  }

  route {
    cidr_block = var.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "route_table_private-tf"
  }

  depends_on = [aws_nat_gateway.nat, aws_vpc.main, aws_subnet.private]
}

resource "aws_route_table_association" "subnets_public" {
  for_each       = var.subnets_public
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id

  depends_on = [aws_route_table.public]
}

resource "aws_route_table_association" "subnets_private" {
  for_each       = var.subnets_private
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id

  depends_on = [aws_route_table.private]
}

resource "aws_nat_gateway" "nat" {
  for_each      = var.nat_gws
  allocation_id = aws_eip.eip_nat[each.key].id
  subnet_id     = aws_subnet.public[each.value.subnet_to_place_nat].id

  tags = {
    Name = "${each.value.name}-${each.value.subnet_to_place_nat}"
  }

  depends_on = [aws_internet_gateway.gw, aws_subnet.public, aws_eip.eip_nat]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.internet_gw_name
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public" {
  for_each                = var.subnets_public
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.public_ip_on_launch

  tags = {
    Name = each.value.name
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "private" {
  for_each          = var.subnets_private
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.availability_zone

  tags = {
    Name = each.value.name
  }
  depends_on = [aws_vpc.main, aws_subnet.public]
}
