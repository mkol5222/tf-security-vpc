
module "gateway_load_balancer" {
  source = "../../modules/common/load_balancer"

  load_balancers_type = "gateway"
  instances_subnets = var.chkp_gw_subnet_ids
  prefix_name = var.gateway_load_balancer_name
  internal = true

  security_groups = []
  tags = {
    x-chkp-management = var.cme_management_server
    x-chkp-template = var.cme_configuration_template
  }
  vpc_id = var.vpc_id
  load_balancer_protocol = "GENEVE"
  target_group_port = 6081
  listener_port = 6081
  cross_zone_load_balancing = var.enable_cross_zone_load_balancing
}

