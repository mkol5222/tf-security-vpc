
// VPC
module "launch_vpc" {
  source = "../../modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnets_map  = var.public_subnets_map
  private_subnets_map = var.private_subnets_map
  tgw_subnets_map     = var.tgw_subnets_map
  subnets_bit_length  = var.subnets_bit_length
}

// NAT GW
resource "aws_eip" "nat_gw_public_address" {
    for_each = { for i, s in module.launch_vpc.private_subnets_ids_list : i => s }
    vpc = true
}

data "aws_subnet" "private_subnet" {
  for_each = { for i, s in module.launch_vpc.private_subnets_ids_list : i => s }
  id       = each.value
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = { for i, s in module.launch_vpc.private_subnets_ids_list : i => s }
  // depends_on = [aws_subnet.aws_subnet[each.key], aws_eip.nat_gw_public_address[each.key]]
  allocation_id = aws_eip.nat_gw_public_address[each.key].id
  subnet_id     = each.value

  tags = {
    Name = "natgw-chkp-${each.key+1}"
  }
}

resource "aws_route_table" "nat_gw_subnet_rtb" {
  for_each = { for i, s in module.launch_vpc.private_subnets_ids_list : i => s }
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
    Name = "rt-net-chkp-nat-${each.key+1}"
    Network = "Public"
  }
}

resource "aws_route_table_association" "nat_gw_subnet_rtb_assoc" {
  for_each = { for i, s in module.launch_vpc.private_subnets_ids_list : i => s }
  subnet_id      = each.value
  route_table_id = aws_route_table.nat_gw_subnet_rtb[each.key].id
}

// TGW subnet routing via NAT

data "aws_subnet" "tgw-subnets" {
    for_each = { for i, s in module.launch_vpc.tgw_subnets_ids_list : i => s }
    id = each.value
} 

resource "aws_route_table" "rt-net-chkp-tgw" {
    for_each = { for i, s in module.launch_vpc.tgw_subnets_ids_list : i => s }
    vpc_id = module.launch_vpc.vpc_id
    
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway[each.key].id 
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

