data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "amzn2-ami-hvm*"
}

resource "aws_security_group" "ssm_endpoint_sg" {
  name        = "ssm-ec2-endpoints"
  description = "Allow TLS inbound traffic for SSM/EC2 endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  tags = {
    Name = "ssm-ec2-endpoints"
  }
}

resource "aws_security_group" "ssm_host_sg" {
  name        = "ssm_host_sg"
  description = "Allow all traffic from VPCs inbound and all outbound"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssm_host_sg"
  }
}

resource "aws_instance" "ssm_host" {
  for_each = { for i, s in var.subnets_ids_list : i => s }
  ami                    = data.aws_ami.amazon-linux-2.id
  subnet_id              = each.value
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ssm_host_sg.id]
  tags = {
    Name = "ssm-host-${each.key+1}"
    "res" = "${each.key % 2}"
    "x-martin-allow-internet-access" = each.key % 2 == 1 ? "true" : "false"
  }
  user_data = file("${path.module}/install-nginx.sh")
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.subnets_ids_list
  security_group_ids = [
    aws_security_group.ssm_endpoint_sg.id
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_messages_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.subnets_ids_list
  security_group_ids = [
    aws_security_group.ssm_endpoint_sg.id
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_ec2messages_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.subnets_ids_list
  security_group_ids = [
    aws_security_group.ssm_endpoint_sg.id
  ]
  private_dns_enabled = true
}

resource "aws_iam_role" "instance_role" {
  name               = "session-manager-instance-profile-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "session-manager-instance-profile"
  role = aws_iam_role.instance_role.name
}


resource "aws_iam_role_policy_attachment" "instance_role_policy_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}