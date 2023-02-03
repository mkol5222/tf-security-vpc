
variable "subnet_id" {
  type = string
  description = "Subnet IDs to launch host with SSM configured into."
}

variable "vpc_id" {
  type = string
  description = "VPC id"
}

variable "region" {
  type = string
  description = "AWS region"
  default = ""
}