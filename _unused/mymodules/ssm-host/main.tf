resource "aws_security_group" "ssm_endpoint_sg" {
  name        = "ssm-ec2-endpoints"
  description = "Allow TLS inbound traffic for SSM/EC2 endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // [aws_vpc.spoke_vpc_b.cidr_block]
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
    cidr_blocks = ["0.0.0.0/0"] // [aws_vpc.spoke_vpc_a.cidr_block, aws_vpc.spoke_vpc_b.cidr_block]
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
  ami                    = data.aws_ami.amazon-linux-2.id
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ssm_host_sg.id]
  tags = {
    Name = "ssm-host"
  }
  user_data = file("./install-nginx.sh")
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [var.subnet_id]
  security_group_ids = [
    aws_security_group.ssm_endpoint_sg.id
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_messages_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [var.subnet_id]
  security_group_ids = [
    aws_security_group.ssm_endpoint_sg.id
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_ec2messages_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [var.subnet_id]
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