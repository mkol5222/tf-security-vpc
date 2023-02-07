
module "instanceA" {
  source = "./mymodules/ssm-host"
    region = "eu-central-1"
    vpc_id = module.launch_vpc.vpc_id
    subnet_id = module.launch_vpc.tgw_subnets_ids_list[0]
}