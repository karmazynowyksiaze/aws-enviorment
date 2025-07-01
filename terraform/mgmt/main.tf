data "aws_region" "current" {}

resource "aws_vpc" "mgmt_infrastructure_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "CI/CD VPN"
  }
}

resource "aws_internet_gateway" "mgmt_infrastructure_gateway" {
  vpc_id = aws_vpc.mgmt_infrastructure_vpc.id

  tags = {
    Name = "CI/CD IGW"
  }
}

resource "aws_subnet" "mgmt_infrastructure_subnet" {
  vpc_id            = aws_vpc.mgmt_infrastructure_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "CI/CD Public Subnet"
  }
}

resource "aws_route_table" "mgmt_infrastructure_route_table" {
  vpc_id = aws_vpc.mgmt_infrastructure_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mgmt_infrastructure_gateway.id
  }

  tags = {
    Name = "CI/CD Public Route Table"
  }
}

resource "aws_route_table_association" "mgmt_infrastructure_route_table_association" {
  subnet_id      = aws_subnet.mgmt_infrastructure_subnet.id
  route_table_id = aws_route_table.mgmt_infrastructure_route_table.id
}

resource "aws_instance" "ec2" {
  count                       = var.instance_count
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = "EC2KeyPair"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.mgmt_infrastructure_subnet.id
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.web.id,
    aws_security_group.monitoring.id,
    aws_security_group.jenkins.id
  ]

  tags = {
    Name = element(var.instance_tags, count.index)
  }
}