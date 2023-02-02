// VPC
module "launch_vpc" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnets_map  = var.public_subnets_map
  private_subnets_map = {}
  tgw_subnets_map     = var.tgw_subnets_map
  subnets_bit_length  = var.subnets_bit_length
}

// NAT gw
resource "aws_subnet" "nat_gw_subnet1" {
  vpc_id = module.launch_vpc.vpc_id
  availability_zone = element(var.availability_zones, 0)
  cidr_block = var.nat_gw_subnet_1_cidr
  tags = {
    Name = "net-chkp-nat-1"
    Network = "Private"
  }
}

resource "aws_subnet" "nat_gw_subnet2" {
  vpc_id = module.launch_vpc.vpc_id
  availability_zone = element(var.availability_zones, 1)
  cidr_block = var.nat_gw_subnet_2_cidr
  tags = {
    Name = "net-chkp-nat-2"
    Network = "Private"
  }
}

resource "aws_subnet" "nat_gw_subnet3" {
  count = var.number_of_AZs >= 3 ? 1 :0
  vpc_id = module.launch_vpc.vpc_id
  availability_zone = element(var.availability_zones, 2)
  cidr_block = var.nat_gw_subnet_3_cidr
  tags = {
    Name = "net-chkp-nat-3"
    Network = "Private"
  }
}

resource "aws_eip" "nat_gw_public_address1" {
  vpc = true
}
resource "aws_eip" "nat_gw_public_address2" {
  vpc = true
}
resource "aws_eip" "nat_gw_public_address3" {
  count = var.number_of_AZs >= 3 ? 1 :0
  vpc = true
}
resource "aws_eip" "nat_gw_public_address4" {
  count = var.number_of_AZs >= 4 ? 1 :0
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway1" {
  depends_on = [aws_subnet.nat_gw_subnet1, aws_eip.nat_gw_public_address1]
  allocation_id = aws_eip.nat_gw_public_address1.id
  subnet_id     = aws_subnet.nat_gw_subnet1.id

  tags = {
    Name = "natgw-chkp-1"
  }
}
resource "aws_nat_gateway" "nat_gateway2" {
  depends_on = [aws_subnet.nat_gw_subnet2, aws_eip.nat_gw_public_address2]
  allocation_id = aws_eip.nat_gw_public_address2.id
  subnet_id     = aws_subnet.nat_gw_subnet2.id

  tags = {
    Name = "natgw-chkp-2"
  }
}
resource "aws_nat_gateway" "nat_gateway3" {
  count = var.number_of_AZs >= 3 ? 1 :0
  depends_on = [aws_subnet.nat_gw_subnet3, aws_eip.nat_gw_public_address3]
  allocation_id = aws_eip.nat_gw_public_address3[0].id
  subnet_id     = aws_subnet.nat_gw_subnet3[0].id

  tags = {
    Name = "natgw-chkp-3"
  }
}

resource "aws_route_table" "nat_gw_subnet1_rtb" {
  vpc_id = module.launch_vpc.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = module.launch_vpc.aws_igw
  }
/*   route{
    cidr_block = "10.0.0.0/8"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint1.id
  }
  route{
    cidr_block = "172.16.0.0/12"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint1.id
  }
  route{
    cidr_block = "192.168.0.0/16"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint1.id
  } */

  tags = {
    Name = "rt-net-chkp-nat-1"
    Network = "Public"
  }
}
resource "aws_route_table_association" "nat_gw_subnet1_rtb_assoc" {
  subnet_id      = aws_subnet.nat_gw_subnet1.id
  route_table_id = aws_route_table.nat_gw_subnet1_rtb.id
}

resource "aws_route_table" "nat_gw_subnet2_rtb" {
  vpc_id = module.launch_vpc.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = module.launch_vpc.aws_igw
  }
/*   route{
    cidr_block = "10.0.0.0/8"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint1.id
  }
  route{
    cidr_block = "172.16.0.0/12"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint1.id
  }
  route{
    cidr_block = "192.168.0.0/16"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint1.id
  } */

  tags = {
    Name = "rt-net-chkp-nat-2"
    Network = "Public"
  }
}
resource "aws_route_table_association" "nat_gw_subnet2_rtb_assoc" {
  subnet_id      = aws_subnet.nat_gw_subnet2.id
  route_table_id = aws_route_table.nat_gw_subnet2_rtb.id
}

resource "aws_route_table" "nat_gw_subnet3_rtb" {
  vpc_id = module.launch_vpc.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = module.launch_vpc.aws_igw
  }
/*   route{
    cidr_block = "10.0.0.0/8"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint1.id
  }
  route{
    cidr_block = "172.16.0.0/12"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint1.id
  }
  route{
    cidr_block = "192.168.0.0/16"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoint1.id
  } */

  tags = {
    Name = "rt-net-chkp-nat-3"
    Network = "Public"
  }
}
resource "aws_route_table_association" "nat_gw_subnet3_rtb_assoc" {
  subnet_id      = aws_subnet.nat_gw_subnet3[0].id
  route_table_id = aws_route_table.nat_gw_subnet3_rtb.id
}


output "tgw-subnets" {
    value =  module.launch_vpc.tgw_subnets_ids_list
}  

data "aws_subnet" "tgw-subnets" {
    for_each = { for i, s in module.launch_vpc.tgw_subnets_ids_list : i => s }
    id = each.value
}

output "tgs-subnets-detail" {
    value = data.aws_subnet.tgw-subnets
}

output "nat-gws" {
    value = [aws_nat_gateway.nat_gateway1.id, aws_nat_gateway.nat_gateway2.id, aws_nat_gateway.nat_gateway3[0].id]
}

locals {
   ngws = [aws_nat_gateway.nat_gateway1.id, aws_nat_gateway.nat_gateway2.id, aws_nat_gateway.nat_gateway3[0].id] 
}

resource "null_resource" "rtb-test4" {
   // for_each = var.tgw_subnets_map
   for_each = { for i, v in values(var.tgw_subnets_map) : i => v }

    triggers = {
        name = "${each.value}: ${each.key}"
        key = tonumber(each.key)+1
        other = local.ngws[each.key]
  }
}
output "rts-test" {
  value = null_resource.rtb-test4
}


 resource "aws_route_table" "rt-net-chkp-tgw" {
    for_each = { for i, s in module.launch_vpc.tgw_subnets_ids_list : i => s }
    vpc_id = module.launch_vpc.vpc_id
    
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = local.ngws[each.key] 
    }
    
    tags = {
         Name = "rt-${data.aws_subnet.tgw-subnets[each.key].tags["Name"]}"
    }
}  

resource "aws_route_table_association" "tgw_subnet_rtb_assoc" {
  for_each = { for i, s in module.launch_vpc.tgw_subnets_ids_list : i => s }
  subnet_id      = data.aws_subnet.tgw-subnets[each.key].id
  route_table_id = aws_route_table.rt-net-chkp-tgw[each.key].id
}
