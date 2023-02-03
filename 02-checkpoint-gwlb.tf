
locals {
    // gwlb_subnet_ids = output.chkp_gw_subnet_ids
    vpc_id = module.launch_vpc.vpc_id // gwlb_subnet_ids =  var.gw_subnet_ids
}

module "gateway_load_balancer" {
  source = "./modules/common/load_balancer"

  load_balancers_type = "gateway"
  instances_subnets = local.chkp_gw_subnet_ids
  prefix_name = var.gateway_load_balancer_name
  internal = true

  security_groups = []
  tags = {
    x-chkp-management = var.management_server
    x-chkp-template = var.configuration_template
  }
  vpc_id = local.vpc_id //var.vpc_id
  load_balancer_protocol = "GENEVE"
  target_group_port = 6081
  listener_port = 6081
  cross_zone_load_balancing = var.enable_cross_zone_load_balancing
}