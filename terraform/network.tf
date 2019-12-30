locals {
  subnets = {
    "${var.region}a" = "10.0.0.0/21"
    "${var.region}b" = "10.0.8.0/21"
    "${var.region}c" = "10.0.16.0/21"
  }
}

resource "aws_vpc" "neoway-app-vpc" {
  enable_dns_hostnames = true
  enable_dns_support   = true
  cidr_block           = "10.0.0.0/16"

  tags = {
    Name = "neoway-app-vpc"
  }
}

resource "aws_internet_gateway" "neoway-app-ig" {
  vpc_id = aws_vpc.neoway-app-vpc.id

  tags = {
    Name = "neoway-app-internet-ig"
  }
}

resource "aws_subnet" "neoway-app-subnet" {
  count                   = length(local.subnets)
  cidr_block              = element(values(local.subnets), count.index)
  vpc_id                  = aws_vpc.neoway-app-vpc.id
  map_public_ip_on_launch = true
  availability_zone       = element(keys(local.subnets), count.index)

  tags = {
    Name = element(keys(local.subnets), count.index)
  }
}

resource "aws_route_table" "neoway-app-route" {
  vpc_id = aws_vpc.neoway-app-vpc.id

  tags = {
    Name = "neoway-app-public-route"
  }
}

resource "aws_route" "neoway-app-rt" {
  route_table_id         = aws_route_table.neoway-app-route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.neoway-app-ig.id
}

resource "aws_route_table_association" "this" {
  count = length(local.subnets)
  route_table_id = aws_route_table.neoway-app-route.id
  subnet_id = element(aws_subnet.neoway-app-subnet.*.id, count.index)
}

resource "aws_security_group" "neoway-app-ebs-sg" {
    name   = "neoway-app-ebs-traffic"
    vpc_id = aws_vpc.neoway-app-vpc.id
    ingress {
        from_port   = 5000
        protocol    = "tcp"
        to_port     = 5000
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.ssh_allowed_ips
    }

    egress {
        from_port   = 0
        protocol    = "-1"
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}
