
// VPC
module "launch_vpc" {
  source = "../modules/vpc"

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


// CHKP GW subnets

data "aws_vpc" "selected" {
  id = module.launch_vpc.vpc_id
}

resource "aws_subnet" "chkp_gw_subnet" {
  for_each = var.gw_subnets_map

  vpc_id = module.launch_vpc.vpc_id
  availability_zone = each.key
  cidr_block = cidrsubnet(data.aws_vpc.selected.cidr_block, var.subnets_bit_length, each.value)
  map_public_ip_on_launch = true
  tags = {
    Name = format("net-chkp-gw-%s", each.value)
    Network = "Public"
  }
}

resource "aws_route_table" "gw_subnet_rtb" {
  vpc_id = module.launch_vpc.vpc_id
  tags = {
    Name = "rt-net-chkp-gw"
  }
}
resource "aws_route" "vpc_internet_access" {
  route_table_id = aws_route_table.gw_subnet_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = module.launch_vpc.aws_igw
}

resource "aws_route_table_association" "public_rtb_to_gw_subnets" {
  for_each = { for i, gw_subnet in aws_subnet.chkp_gw_subnet : i => gw_subnet.id }
  route_table_id = aws_route_table.gw_subnet_rtb.id
  subnet_id = each.value
}


// GWLBe subnets

// GWLBe
resource "aws_subnet" "gwlbe_subnet" {
  for_each = var.gwlbe_subnets_map

  vpc_id =  module.launch_vpc.vpc_id
  availability_zone = each.key
  cidr_block = cidrsubnet(data.aws_vpc.selected.cidr_block, var.subnets_bit_length, each.value)
  tags = {
    Name = "net-chkp-gwlbe-${each.value}"
    Network = "Private"
  }
}
resource "aws_route_table" "gwlbe_subnet_rtb" {
  for_each = var.gwlbe_subnets_map
  vpc_id =  module.launch_vpc.vpc_id

  tags = {
    Name = "rt-net-chkp-gwlbe-${each.value}"
    Network = "Private"
  }
}


resource "aws_route" "gwlbe_subnet_rtb_default" {
  for_each = { for i, az in keys(var.gwlbe_subnets_map) : i => az }
  route_table_id            = aws_route_table.gwlbe_subnet_rtb[each.value].id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            =  aws_nat_gateway.nat_gateway[each.key].id
} 

resource "aws_route_table_association" "gwlbe_subnet_rtb_assoc" {
  for_each = { for i, az in keys(var.gwlbe_subnets_map) : i => az }
  subnet_id      = aws_subnet.gwlbe_subnet[each.value].id
  route_table_id = aws_route_table.gwlbe_subnet_rtb[each.value].id
} 
