
// AZs
data "aws_availability_zones" "available" {
  state = "available"
}
output "azs" {
    value = data.aws_availability_zones.available.names
}

// discover TGW subnet ids
data "aws_subnet_ids" "tgw_subnet_ids" {
  vpc_id = var.vpc_id

  tags = {
    Name = "net-chkp-tgw-*"
  }
}

// get TGW subnets from ID list
data "aws_subnet" "tgw_subnet" {
  for_each = data.aws_subnet_ids.tgw_subnet_ids.ids
  id       = each.value
} 

// route tables
data "aws_route_table" "tgw" {
  for_each = data.aws_subnet_ids.tgw_subnet_ids.ids
  subnet_id = each.value
}

locals {
    azs = data.aws_availability_zones.available.names
    tgw_subnet_id_by_az = {for s in data.aws_subnet.tgw_subnet :  s.availability_zone => s.id  }
    tgw_subnet_a = local.tgw_subnet_id_by_az[local.azs[0]]
    tgw_subnet_b = local.tgw_subnet_id_by_az[local.azs[1]]
    tgw_subnet_c = local.tgw_subnet_id_by_az[local.azs[2]]
    tgw_rt_a = data.aws_route_table.tgw[local.tgw_subnet_a].id
    tgw_rt_b = data.aws_route_table.tgw[local.tgw_subnet_b].id
    tgw_rt_c = data.aws_route_table.tgw[local.tgw_subnet_c].id
    gwlbe_a = aws_vpc_endpoint.gwlb_endpoint["0"].id
    gwlbe_b = aws_vpc_endpoint.gwlb_endpoint["1"].id
    gwlbe_c = aws_vpc_endpoint.gwlb_endpoint["2"].id
}

output "tgw_rt_a" {
    value = local.tgw_rt_a
}
output "tgw_rt_b" {
    value = local.tgw_rt_b
}
output "tgw_rt_c" {
    value = local.tgw_rt_c
}

output "gwlbe_a" {
    value = local.gwlbe_a
}
output "gwlbe_b" {
    value = local.gwlbe_b
}
output "gwlbe_c" {
    value = local.gwlbe_c
}


output "tgw-subnet-ids-by-az" {
    value = {for s in data.aws_subnet.tgw_subnet :  s.availability_zone => s.id  }
}

output "tgw-subnets" {
    value = data.aws_subnet.tgw_subnet
}

output "tgw-route-tables" {
    value = data.aws_route_table.tgw
}