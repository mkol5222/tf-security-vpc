
data "aws_subnet_ids" "tgw_subnet_ids" {
  vpc_id = var.vpc_id

  tags = {
    Name = "net-chkp-tgw-*"
  }
}

output "tgw_subnet_ids" {
    value = data.aws_subnet_ids.tgw_subnet_ids.ids
}