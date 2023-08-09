module "env" {
  source = "./01-test-env"
  region = "eu-west-1"
  // VPC 
  vpc_cidr = "10.250.0.0/16"

  public_subnets_map = {
    "eu-west-1a" = 1
    "eu-west-1b" = 2
    "eu-west-1c" = 3
  }

  tgw_subnets_map = {
    "eu-west-1a" = 5
    "eu-west-1b" = 6
    "eu-west-1c" = 7
  }

  private_subnets_map = {
    "eu-west-1a" = 11
    "eu-west-1b" = 12
    "eu-west-1c" = 13
  }

  gw_subnets_map = {
    "eu-west-1a" = 21
    "eu-west-1b" = 22
    "eu-west-1c" = 23
  }

  // gwlbe_subnets_map
  gwlbe_subnets_map = {
    "eu-west-1a" = 31
    "eu-west-1b" = 32
    "eu-west-1c" = 33
  }

  subnets_bit_length = 8
}

module "instances" {
  source = "./02-instances"

  vpc_id = module.env.vpc_id
  region = "eu-west-1"

  subnets_ids_list = module.env.subnets_ids_list

}

module "chkp" {
  source = "./03-chkp-gwlb"

  vpc_id = module.env.vpc_id
  region = "eu-west-1"

  // 
  chkp_gw_subnets_ids_list = module.env.chkp_gw_subnets_ids_list

  chkp_gwlbe_subnets_ids_list = module.env.chkp_gwlbe_subnets_ids_list

  // place into traffic?
  route_via_gwlb = false

  // GWLB
  gateway_load_balancer_name       = "chkp-gwlb"
  enable_cross_zone_load_balancing = true
  // GWLBe
  connection_acceptance_required = false

  // CME
  cme_management_server           = "chkp-mgmt"
  cme_configuration_template      = "chkp-gwlb-template"
  gateways_policy                 = "Standard" //"GWLBpolicy" // or Standard ?
  allocate_public_IP              = true
  gateways_provision_address_type = "public"

  // gateways
  gateway_name          = "gwlb-chkp-gw"
  gateway_instance_type = "c5.xlarge" // "c5.large"
  key_name              = "mko-t14"   // SSH key pair name
  admin_shell           = "/bin/bash"

  gateway_SICKey          = "Vpn123546Vpn"
  gateway_password_hash   = "$1$J4Z6eE9e$QHd2tsbdJRzgD0Ju.iYdb/" // "9eFRyaV07lHXc"
  gateway_version         =  "R81.20-BYOL"  // "R80.40-BYOL" // "R81.20-BYOL" // "R80.40-BYOL"
  minimum_group_size      = 3
  maximum_group_size      = 6
  enable_instance_connect = true
}

output "cme_command" {
  value = module.chkp.cme-command
    sensitive = true
}

// cmd_fw_on
output "cmd_fw_on" {
  value = module.chkp.cmd_fw_on

}

output "cmd_fw_off" {
  value = module.chkp.cmd_fw_off

}
