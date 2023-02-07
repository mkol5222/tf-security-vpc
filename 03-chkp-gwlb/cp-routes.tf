
data "aws_subnet_ids" "tgw_subnet_ids" {
  vpc_id = var.vpc_id

  tags = {
    Name = "net-chkp-tgw-*"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

output "tgw_subnet_ids" {
    value = data.aws_subnet_ids.tgw_subnet_ids.ids
}

output "azs" {
    value = data.aws_availability_zones.available.names
}

data "aws_subnet" "tgw_subnets" {
  for_each = data.aws_subnet_ids.tgw_subnet_ids.ids
  id       = each.value
} 

output "tgw_subnet_cidr_blocks" {
  value = {for s in data.aws_subnet.tgw_subnets : s.availability_zone => s.cidr_block}
}