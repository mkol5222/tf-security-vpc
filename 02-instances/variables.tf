variable "vpc_id" {
  type = string
  description = "VPC id to deploy to"
}

variable "region" {
  type = string
  description = "AWS region"
}

variable "subnets_ids_list" {
  type = list(string)
  description = "list of subnet ids to deploy instance to"
}