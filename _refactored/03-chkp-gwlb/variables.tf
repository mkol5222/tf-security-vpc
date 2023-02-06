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

variable "chkp_gwlbe_subnets_ids" {
  type = list(string)
  description = "list of subnet ids to deploy GWLBe instances to"
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

