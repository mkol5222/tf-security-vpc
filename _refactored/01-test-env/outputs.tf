
/* output "private_subnets_ids_list" {
  value = module.launch_vpc.private_subnets_ids_list
} */

output "tgw_subnets_ids_list" {
  value = module.launch_vpc.tgw_subnets_ids_list
}

output "chkp_gw_subnets_ids_list" {
  value = [for gw_subnet in aws_subnet.chkp_gw_subnet : gw_subnet.id]
}

output "vpc_id" {
  value = module.launch_vpc.vpc_id
}