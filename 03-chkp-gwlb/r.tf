
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

output "tgw-subnet-ids-by-az" {
    value = {for s in data.aws_subnet.tgw_subnet :  s.availability_zone => s.id  }
}

output "tgw-subnets" {
    value = data.aws_subnet.tgw_subnet
}