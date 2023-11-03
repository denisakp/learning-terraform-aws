locals {
  public_subnets = [for subnet in aws_subnet.subnets : subnet if subnet.map_public_ip_on_launch == true]
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_blocks
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "subnets" {
  count = length(var.subnets)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnets[count.index].cidr_block
  availability_zone       = var.subnets[count.index].availability_zone
  map_public_ip_on_launch = var.subnets[count.index].map_public_ip_on_launch

  tags = {
    "Name" = var.subnets[count.index].name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = var.igw
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "rtb_association" {
  count = length(local.public_subnets)

  subnet_id      = local.public_subnets[count.index].id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_security_group" "allow_ssh_sg" {
  name        = "${var.project_name}AllowSSH"
  description = "Allow SSH connection on mantis EC2s"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh conection from everywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http_sg" {
  name        = "${var.project_name}AllowHTTP"
  description = "Allow incoming web trafic web traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "tls" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_secretsmanager_secret" "aws_secret" {
  description = "TLS private key secret"
  name        = "${var.project_name}-private-key"
}

resource "aws_secretsmanager_secret_version" "name" {
  secret_id     = aws_secretsmanager_secret.aws_secret.id
  secret_string = tostring(tls_private_key.tls.private_key_pem)
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.project_name}-key-pair"
  public_key = tls_private_key.tls.public_key_openssh
}

resource "aws_launch_template" "launch_template" {
  image_id      = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = var.instance_type
  name_prefix   = "${var.project_name}-"

  key_name = aws_key_pair.key_pair.key_name

  vpc_security_group_ids = [aws_security_group.allow_http_sg.id, aws_security_group.allow_ssh_sg.id]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name" = "${var.project_name} Web server launch template"
  }
}

resource "random_shuffle" "random_pb_subnet" {
  input        = tolist([for subnet in local.public_subnets : subnet.id])
  result_count = 1
}

resource "aws_instance" "ec2" {
  launch_template {
    id      = aws_launch_template.launch_template.id
    name    = aws_launch_template.launch_template.name
    version = "$Latest"
  }

  subnet_id = random_shuffle.random_pb_subnet.result[0]

  tags = {
    "Name" = "${var.project_name}-web-srv"
  }
}

