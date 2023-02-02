variable "region" {
  type = string
  description = "AWS region"
  default = ""
}

variable "number_of_AZs" {
  type = number
  description = "Number of Availability Zones to use in the VPC. This must match your selections in the list of Availability Zones parameter"
  default = 3
}
variable "availability_zones"{
  type = list(string)
  description = "The Availability Zones (AZs) to use for the subnets in the VPC. Select two (the logical order is preserved)"
}

// VPC
variable "vpc_cidr" {
  type = string
  description = "The CIDR block of the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnets_map" {
  type = map(string)
  description = "A map of pairs {availability-zone = subnet-suffix-number}. Each entry creates a subnet. Minimum 2 pairs.  (e.g. {\"us-east-1a\" = 1} ) "
}

variable "tgw_subnets_map" {
  type = map(string)
  description = "A map of pairs {availability-zone = subnet-suffix-number} for the tgw subnets. Each entry creates a subnet. Minimum 2 pairs.  (e.g. {\"us-east-1a\" = 1} ) "
}

variable "subnets_bit_length" {
  type = number
  description = "Number of additional bits with which to extend the vpc cidr. For example, if given a vpc_cidr ending in /16 and a subnets_bit_length value of 4, the resulting subnet address will have length /20"
}

// NAT gw
variable "nat_gw_subnet_1_cidr" {
  type = string
  description = "CIDR block for NAT subnet 1 located in the 1st Availability Zone"
  default = "10.0.13.0/24"
}
variable "nat_gw_subnet_2_cidr" {
  type = string
  description = "CIDR block for NAT subnet 2 located in the 2st Availability Zone"
  default = "10.0.23.0/24"
}
variable "nat_gw_subnet_3_cidr" {
  type = string
  description = "CIDR block for NAT subnet 3 located in the 3st Availability Zone"
  default = "10.0.33.0/24"
}
variable "nat_gw_subnet_4_cidr" {
  type = string
  description = "CIDR block for NAT subnet 4 located in the 4st Availability Zone"
  default = "10.0.43.0/24"
}
