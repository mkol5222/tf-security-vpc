variable "vpc_id" {
  type = string
  description = "VPC id to deploy to"
}

variable "region" {
  type = string
  description = "AWS region"
}

variable "chkp_gw_subnet_ids" {
  type = list(string)
  description = "list of subnet ids to deploy GW instances to"
}

variable "chkp_gwlbe_subnets_ids_list" {
  type = list(string)
  description = "list of subnet ids to deploy GWLBe instances to"
}

variable "tgw_subnet_name_list" {
  type = list(string)
  description = "list of TGW subnet names"
  default = ["net-chkp-tgw-5", "net-chkp-tgw-6", "net-chkp-tgw-7"]
}

// GWLB config
variable "gateway_load_balancer_name" {
  type = string
  description =  "Gateway Load Balancer name. This name must be unique within your AWS account and can have a maximum of 32 alphanumeric characters and hyphens. A name cannot begin or end with a hyphen."
  default = "gwlb1"
}
variable "enable_cross_zone_load_balancing" {
  type = bool
  description =  "Select 'true' to enable cross-az load balancing. NOTE! this may cause a spike in cross-az charges."
  default = true
}

// GWLBe
variable "connection_acceptance_required" {
  type = bool
  description =  "Indicate whether requests from service consumers to create an endpoint to your service must be accepted. Default is set to false(acceptance not required)."
  default = false
}

// CME
variable "cme_management_server" {
  type = string
  description = "The name that represents the Security Management Server in the automatic provisioning configuration."
  default = "gwlb-management-server"
}
variable "cme_configuration_template" {
  type = string
  description = "A name of a gateway configuration template in the automatic provisioning configuration."
  default = "gwlb-ASG-configuration"
}

// gw
variable "gateway_name" {
  type = string
  description = "The name tag of the Security Gateway instances. (optional)"
  default = "Check-Point-Gateway-tf"
}
variable "gateway_instance_type" {
  type = string
  description = "The EC2 instance type for the Security Gateways."
  default = "c5.xlarge"
}
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instances"
}
variable "admin_shell" {
  type = string
  description = "Set the admin shell to enable advanced command line configuration"
  default = "/etc/cli.sh"
}
variable "gateways_provision_address_type" {
  type = string
  description = "Determines if the gateways are provisioned using their private or public address"
  default = "private"
}

variable "gateway_version" {
  type = string
  description =  "The version and license to install on the Security Gateways."
  default = "R80.40-BYOL"
}
module "validate_gateway_version" {
  source = "../modules/common/version_license"

  chkp_type = "gwlb_gw"
  version_license = var.gateway_version
}
variable "gateway_password_hash" {
  type = string
  description = "(Optional) Admin user's password hash (use command 'openssl passwd -6 PASSWORD' to get the PASSWORD's hash)"
}
variable "gateway_SICKey" {
  type = string
  description = "The Secure Internal Communication key for trusted connection between Check Point components (at least 8 alphanumeric characters)"
}


variable "allocate_public_IP" {
  type = bool
  description = "Allocate an Elastic IP for security gateway."
  default = false
}

resource "null_resource" "invalid_allocation" {
  // Will fail if var.gateways_provision_address_type is public and var.allocate_public_IP is false
  count = var.gateways_provision_address_type != "public" ? 0 : var.allocate_public_IP == true ? 0 : "Gateway's selected to be provisioned by public IP, but [allocate_public_IP] parameter is false"
}

variable "enable_volume_encryption" {
  type = bool
  description = "Encrypt Environment instances volume with default AWS KMS key"
  default = true
}
variable "volume_size" {
  type = number
  description = "Root volume size (GB) - minimum 100"
  default = 100
}
resource "null_resource" "volume_size_too_small" {
  // Will fail if var.volume_size is less than 100
  count = var.volume_size >= 100 ? 0 : "variable volume_size must be at least 100"
}
variable "volume_type" {
  type = string
  description = "General Purpose SSD Volume Type"
  default = "gp3"
}
variable "allow_upload_download" {
  type = bool
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
  default = true
}
variable "enable_cloudwatch" {
  type = bool
  description = "Report Check Point specific CloudWatch metrics."
  default = false
}

variable "minimum_group_size" {
  type = number
  description = "The minimal number of Security Gateways."
  default = 2
}
variable "maximum_group_size" {
  type = number
  description = "The maximal number of Security Gateways."
  default = 10
}

variable "enable_instance_connect" {
  type = bool
  description = "Enable SSH connection over AWS web console"
  default = false
}
variable "disable_instance_termination" {
  type = bool
  description = "Prevents an instance from accidental termination"
  default = false
}

variable "gateways_policy" {
  type = string
  description = "The name of the Security Policy package to be installed on the gateways in the Security Gateways Auto Scaling group"
  default = "Standard"
}
