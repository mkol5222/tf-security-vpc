
/* output "private_subnets_ids_list" {
  value = module.launch_vpc.private_subnets_ids_list
} */

output "vpc_id" {
  value = module.launch_vpc.vpc_id
}

output "region" {
 value = "eu-central-1"
}

output "subnets_ids_list" {
  value = module.launch_vpc.tgw_subnets_ids_list
}

output "chkp_gw_subnets_ids_list" {
  value = [for gw_subnet in aws_subnet.chkp_gw_subnet : gw_subnet.id]
}

output "chkp_gwlbe_subnets_ids_list" {
  value = [for gwlbe_subnet in aws_subnet.gwlbe_subnet : gwlbe_subnet.id]
}

/* output "aws_route_table_association-tgw" {
  value = aws_route_table_association.tgw_subnet_rtb_assoc[*].id
}

output "aws_route_table_association-nat" {
  value = aws_route_table_association.nat_gw_subnet_rtb_assoc[*].id
} */

