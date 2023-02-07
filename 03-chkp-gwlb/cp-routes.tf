
data "aws_subnet_ids" "tgw_subnet_ids" {
  vpc_id = var.vpc_id

  tags = {
    Name = "net-chkp-tgw-*"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

output "tgw_subnet_ids0" {
    value = data.aws_subnet_ids.tgw_subnet_ids.ids
}

output "azs" {
    value = data.aws_availability_zones.available.names
}

data "aws_subnet" "tgw_net_by_az" {
  for_each = data.aws_subnet_ids.tgw_subnet_ids.ids
  id       = each.value
} 

data "aws_subnet" "tgw_subnets" {
  for_each = data.aws_subnet_ids.tgw_subnet_ids.ids
  id       = each.value
} 

output "tgw_subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.tgw_subnets :  s.cidr_block]
}
output "tgw_subnet_ids" {
  value = [for s in data.aws_subnet.tgw_subnets :  s.id]
}
output "tgw_subnet_names" {
  value = [for s in data.aws_subnet.tgw_subnets :  lookup(s.tags, "Name", "n/a")]
}
output "tgw_subnet_azs" {
    value = [for s in data.aws_subnet.tgw_subnets :  s.availability_zone]
}


data "aws_subnet_ids" "nat_subnet_ids" {
  vpc_id = var.vpc_id

  tags = {
    Name = "net-chkp-private-*"
  }
}

data "aws_nat_gateway" "default" {
  for_each = data.aws_subnet_ids.nat_subnet_ids.ids
  subnet_id = each.value
}

output "nat_gateways" {
    value = data.aws_nat_gateway.default
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

output "igw" {
    value = data.aws_internet_gateway.default
}

data "aws_subnet_ids" "gwlbe_subnet_ids" {
  vpc_id = var.vpc_id

  tags = {
    Name = "net-chkp-gwlbe-*"
  }
}

output "gwlbe_subnet_ids" {
    value = data.aws_subnet_ids.gwlbe_subnet_ids.ids
}

/* data "aws_vpc_endpoint" "gwlbe" {
  for_each = data.aws_subnet_ids.gwlbe_subnet_ids.ids
  vpc_id       = var.vpc_id
 
  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

output "gwlbes" {
    value = data.aws_vpc_endpoint.gwlbe
} */