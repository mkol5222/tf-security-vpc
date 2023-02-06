
output "private_subnets_ids_list" {
  value = module.launch_vpc.private_subnets_ids_list
}

output "tgw_subnets_ids_list" {
  value = module.launch_vpc.tgw_subnets_ids_list
}

output "vpc_id" {
  value = module.launch_vpc.vpc_id
}