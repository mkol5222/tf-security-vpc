
locals {
    // gwlb_subnet_ids = output.chkp_gw_subnet_ids
    vpc_id = module.launch_vpc.vpc_id 
    // gwlb_subnet_ids =  var.gw_subnet_ids
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

module "autoscale_gwlb" {
  source = "./modules/autoscale-gwlb"
  providers = {
    aws = aws
  }
  depends_on = [module.gateway_load_balancer]

  target_groups = module.gateway_load_balancer[*].target_group_arn
  vpc_id = local.vpc_id
  subnet_ids = local.chkp_gw_subnet_ids
  gateway_name = var.gateway_name
  gateway_instance_type = var.gateway_instance_type
  key_name = var.key_name
  enable_volume_encryption = var.enable_volume_encryption
  enable_instance_connect = var.enable_instance_connect
  minimum_group_size = var.minimum_group_size
  maximum_group_size = var.maximum_group_size
  gateway_version = var.gateway_version
  gateway_password_hash = var.gateway_password_hash
  gateway_SICKey = var.gateway_SICKey
  allow_upload_download = var.allow_upload_download
  enable_cloudwatch = var.enable_cloudwatch
  admin_shell = var.admin_shell
  gateway_bootstrap_script = "echo -e '\nStarting Bootstrap script\n'; echo 'Updating cloud-version file'; cv_path='/etc/cloud-version'\n if test -f \"$cv_path\"; then sed -i '/template_name/c\\template_name: autoscale_gwlb' /etc/cloud-version; fi; cv_json_path='/etc/cloud-version.json'\n cv_json_path_tmp='/etc/cloud-version-tmp.json'\n if test -f \"$cv_json_path\"; then cat \"$cv_json_path\" | jq '.template_name = \"'\"autoscale_gwlb\"'\"' > \"$cv_json_path_tmp\"; mv \"$cv_json_path_tmp\" \"$cv_json_path\"; fi; echo -e '\nFinished Bootstrap script\n'"
  gateways_provision_address_type = var.gateways_provision_address_type
  allocate_public_IP = var.allocate_public_IP
  management_server =  var.management_server 
  configuration_template =  var.configuration_template
  volume_type = var.volume_type
}

data "aws_region" "current"{}

output "management_bootstrap_script" {
  value = "echo -e '\nStarting Bootstrap script\n'; echo 'Setting up bootstrap parameters'; cv_path='/etc/cloud-version'\n if test -f \"$cv_path\"; then sed -i '/template_name/c\\template_name: autoscale_gwlb' /etc/cloud-version; fi; cv_json_path='/etc/cloud-version.json'\n cv_json_path_tmp='/etc/cloud-version-tmp.json'\n if test -f \"$cv_json_path\"; then cat \"$cv_json_path\" | jq '.template_name = \"'\"management_gwlb\"'\"' > \"$cv_json_path_tmp\"; mv \"$cv_json_path_tmp\" \"$cv_json_path\"; fi; autoprov_cfg -f init AWS -mn ${var.management_server} -tn ${var.configuration_template} -cn gwlb-controller -po ${var.gateways_policy} -otp ${var.gateway_SICKey} -r ${data.aws_region.current.name} -ver ${split("-", var.gateway_version)[0]} -iam; echo -e '\nFinished Bootstrap script\n'"
}

locals {
  create_iam_role = true
}

module "cme_iam_role" {
  source = "./modules/cme-iam-role"
  providers = {
    aws = aws
  }
  count = local.create_iam_role ? 1 : 0

  sts_roles = var.sts_roles
  permissions = var.iam_permissions
}

output "cme_role_name" {
  value = module.cme_iam_role[0].cme_iam_role_name
}



resource "aws_iam_user" "cme-user" {
  name = "cme-user"

}

resource "aws_iam_access_key" "cme-user-key" {
  user = aws_iam_user.cme-user.name
}

resource "aws_iam_policy_attachment" "cme-policy-attach" {
  name       = "cme-policy-attach"
  users      = [aws_iam_user.cme-user.name]
  policy_arn = module.cme_iam_role[0].cme_read_policy_arn
} 

output "cme-user-key-secret" {
  value = aws_iam_access_key.cme-user-key.secret
  sensitive = true
}

output "cme-user-key-id" {
  value = aws_iam_access_key.cme-user-key.id
  sensitive = false
}

// GWLBe
resource "aws_subnet" "gwlbe_subnet1" {
  vpc_id =  local.vpc_id
  availability_zone = element(var.availability_zones, 0)
  cidr_block = var.gwlbe_subnet_1_cidr
  tags = {
    Name = "net-chkp-gwlbe-1"
    Network = "Private"
  }
}
resource "aws_route_table" "gwlbe_subnet1_rtb" {
  vpc_id =  local.vpc_id

  tags = {
    Name = "rt-net-chkp-gwlbe-1"
    Network = "Private"
  }
}
resource "aws_route" "gwlbe_subnet1_rtb_default" {
  route_table_id            = aws_route_table.gwlbe_subnet1_rtb.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            =  aws_nat_gateway.nat_gateway1.id
}
resource "aws_route_table_association" "gwlbe_subnet1_rtb_assoc" {
  subnet_id      = aws_subnet.gwlbe_subnet1.id
  route_table_id = aws_route_table.gwlbe_subnet1_rtb.id
}

resource "aws_vpc_endpoint_service" "gwlb_endpoint_service" {
  depends_on = [module.gateway_load_balancer]
  gateway_load_balancer_arns = module.gateway_load_balancer[*].load_balancer_arn
  acceptance_required        = var.connection_acceptance_required

  tags = {
    "Name" = "gwlb-endpoint-service-${var.gateway_load_balancer_name}"
  }
}

locals  {
  gwlb_service_name = "com.amazonaws.vpce.${data.aws_region.current.name}.${aws_vpc_endpoint_service.gwlb_endpoint_service.id}"
}

resource "aws_vpc_endpoint" "gwlb_endpoint1" {
  depends_on = [module.gateway_load_balancer, aws_subnet.gwlbe_subnet1]
  vpc_id = local.vpc_id
  vpc_endpoint_type = "GatewayLoadBalancer"
  service_name = local.gwlb_service_name
  subnet_ids = aws_subnet.gwlbe_subnet1[*].id
  tags = {
    "Name" = "gwlb-chkp-endpoint-1"
  }
}

resource "aws_ec2_serial_console_access" "example" {
  enabled = true
}

