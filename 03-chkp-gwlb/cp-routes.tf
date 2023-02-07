


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

output "nat_subnet_id_az" {
    value = {for s in data.aws_subnet.tgw_subnets :  s.id => s.availability_zone}
}
output "nat_az_subnet_id" {
    value = {for s in data.aws_subnet.tgw_subnets :  s.availability_zone => s.id  }
}

locals {
    // nat_az_subnet_id = {for s in data.aws_subnet.tgw_subnets :  s.availability_zone => s.id  }
    nat_subnet_id_az =  {for s in data.aws_subnet.tgw_subnets :  s.id => s.availability_zone}
}

data "aws_subnet_ids" "nat_subnet_ids" {
  vpc_id = var.vpc_id

  tags = {
    Name = "net-chkp-private-*"
  }
}

data "aws_subnet" "nat_subnets" {
  for_each = data.aws_subnet_ids.nat_subnet_ids.ids
  id       = each.value
} 

locals {
    nat_az_subnet_id = {for s in data.aws_subnet.nat_subnets :  s.availability_zone => s.id  }
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


data "aws_subnet" "gwlbe_subnets" {
  for_each = data.aws_subnet_ids.gwlbe_subnet_ids.ids
  id       = each.value
} 


output "gwlbe_subnet_id_az" {
    value = {for s in data.aws_subnet.gwlbe_subnets :  s.id => s.availability_zone}
}
output "gwlbe_az_subnet_id" {
    value = {for s in data.aws_subnet.gwlbe_subnets :  s.availability_zone => s.id  }
}

locals {
    tgw_az_subnet_id = {for s in data.aws_subnet.tgw_subnets :  s.availability_zone => s.id  }
    tgw_subnet_id_az =  {for s in data.aws_subnet.tgw_subnets :  s.id => s.availability_zone}
    gwlbe_subnet_id_az = {for s in data.aws_subnet.gwlbe_subnets :  s.id => s.availability_zone}
    gwlbe_az_subnet_id = {for s in data.aws_subnet.gwlbe_subnets :  s.availability_zone => s.id  }
    nets_gwlbe = values( {for s in data.aws_subnet.gwlbe_subnets :  s.availability_zone => s.id  })
    nets_tgw = values({for s in data.aws_subnet.tgw_subnets :  s.availability_zone => s.id  })
}

output "nets_gwlbe" {
    value = local.nets_gwlbe
}
output "nets_tgw" {
    value = local.nets_tgw
}

data "aws_vpc_endpoint" "gwlbe" {
  for_each = data.aws_subnet_ids.gwlbe_subnet_ids.ids
  vpc_id       = var.vpc_id
 
  filter {
    name   = "tag:subnet_id"
    values = [each.value]
  }
}

output "gwlbes" {
    value = data.aws_vpc_endpoint.gwlbe
}

resource "aws_route_table" "with_cp_fw_nat_gw_subnet_rtb" {
  for_each = {for s in data.aws_subnet.gwlbe_subnets :  s.availability_zone => s.id  }
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default.id
  }
 route{
    cidr_block = "10.250.5.0/24"
    vpc_endpoint_id = data.aws_vpc_endpoint.gwlbe[each.value].id
  }
   route{
    cidr_block = "10.250.6.0/24"
    vpc_endpoint_id = data.aws_vpc_endpoint.gwlbe[each.value].id
  }
   route{
    cidr_block = "10.250.7.0/24"
    vpc_endpoint_id = data.aws_vpc_endpoint.gwlbe[each.value].id
  }


  /*
  route{
    cidr_block = "172.16.0.0/12"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint1.id
  }
  route{
    cidr_block = "192.168.0.0/16"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint1.id
  } */

  tags = {
    Name = "with-cp-fw-rt-net-chkp-nat-${each.value}-${each.key}"
    Network = "Public"
  }
}

/* resource "aws_route_table_association" "nat_gw_subnet_rtb_assoc" {
  for_each = { for i, s in module.launch_vpc.private_subnets_ids_list : i => s }
  subnet_id      = each.value
  route_table_id = aws_route_table.nat_gw_subnet_rtb[each.key].id
} */

resource "aws_route_table" "with_cp_fw_rt-net-chkp-tgw" {
    for_each = {for s in data.aws_subnet.gwlbe_subnets :  s.availability_zone => s.id  }
    vpc_id = var.vpc_id
    
    route {
        cidr_block = "0.0.0.0/0"
        vpc_endpoint_id = data.aws_vpc_endpoint.gwlbe[each.value].id
        // nat_gateway_id = aws_nat_gateway.nat_gateway[local.nat_az_subnet_id[each.key]].id 
    }
    
    tags = {
         Name = "rt-nat-with-fw-${each.key}"
    }
} 