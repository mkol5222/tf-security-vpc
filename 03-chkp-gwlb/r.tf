
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

///

data "aws_subnet_ids" "nat_subnet_ids" {
  vpc_id = var.vpc_id

  tags = {
    Name = "net-chkp-private-*"
  }
}

data "aws_subnet" "nat_subnet" {
  for_each = data.aws_subnet_ids.nat_subnet_ids.ids
  id       = each.value
} 

data "aws_nat_gateway" "default" {
  for_each = data.aws_subnet_ids.nat_subnet_ids.ids
  subnet_id = each.value
}

locals {
    nat_subnet_id_by_az = {for s in data.aws_subnet.nat_subnet :  s.availability_zone => s.id  }
    nat_subnet_a = local.nat_subnet_id_by_az[local.azs[0]]
    nat_subnet_b = local.nat_subnet_id_by_az[local.azs[1]]
    nat_subnet_c = local.nat_subnet_id_by_az[local.azs[2]]

    natgw_a = data.aws_nat_gateway.default[local.nat_subnet_a].id
    natgw_b = data.aws_nat_gateway.default[local.nat_subnet_b].id
    natgw_c = data.aws_nat_gateway.default[local.nat_subnet_c].id

    nat_rt_a = data.aws_route_table.nat[local.nat_subnet_a].id
    nat_rt_b = data.aws_route_table.nat[local.nat_subnet_b].id
    nat_rt_c = data.aws_route_table.nat[local.nat_subnet_c].id
}

output "nat_subnet_a" {
    value = local.nat_subnet_a
}
output "nat_subnet_b" {
    value = local.nat_subnet_b
}
output "nat_subnet_c" {
    value = local.nat_subnet_c
}

output "natgw_a" {
    value = local.natgw_a
}
output "natgw_b" {
    value = local.natgw_b
}
output "natgw_c" {
    value = local.natgw_c
}


data "aws_route_table" "nat" {
  for_each = data.aws_subnet_ids.nat_subnet_ids.ids
  subnet_id = each.value
}

output "nat_rt_a" {
    value = local.nat_rt_a
}
output "nat_rt_b" {
    value = local.nat_rt_b
}
output "nat_rt_c" {
    value = local.nat_rt_c
}


output "cmd_fw_on" {
    value = <<AAA
aws ec2 replace-route --route-table-id ${local.tgw_rt_a} --destination-cidr-block 0.0.0.0/0 --vpc-endpoint-id ${local.gwlbe_a}
aws ec2 replace-route --route-table-id ${local.tgw_rt_b} --destination-cidr-block 0.0.0.0/0 --vpc-endpoint-id ${local.gwlbe_b}
aws ec2 replace-route --route-table-id ${local.tgw_rt_c} --destination-cidr-block 0.0.0.0/0 --vpc-endpoint-id ${local.gwlbe_c}
AAA
}
output "cmd_fw_off" {
    value = <<BBB
aws ec2 replace-route --route-table-id ${local.tgw_rt_a} --destination-cidr-block 0.0.0.0/0 --nat-gateway-id ${local.natgw_a}"
aws ec2 replace-route --route-table-id ${local.tgw_rt_b} --destination-cidr-block 0.0.0.0/0 --nat-gateway-id ${local.natgw_b}"
aws ec2 replace-route --route-table-id ${local.tgw_rt_c} --destination-cidr-block 0.0.0.0/0 --nat-gateway-id ${local.natgw_c}"
BBB
}
