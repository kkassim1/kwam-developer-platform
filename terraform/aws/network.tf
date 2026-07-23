resource "aws_vpc" "platform" {
  count = local.service_count

  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "kwam-platform" }
}

resource "aws_internet_gateway" "platform" {
  count  = local.service_count
  vpc_id = aws_vpc.platform[0].id

  tags = { Name = "kwam-platform" }
}

resource "aws_subnet" "public" {
  count = local.service_count * 2

  vpc_id                  = aws_vpc.platform[0].id
  cidr_block              = cidrsubnet(aws_vpc.platform[0].cidr_block, 8, count.index)
  availability_zone       = "${var.aws_region}${count.index == 0 ? "a" : "b"}"
  map_public_ip_on_launch = true

  tags = { Name = "kwam-platform-public-${count.index + 1}" }
}

resource "aws_route_table" "public" {
  count  = local.service_count
  vpc_id = aws_vpc.platform[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.platform[0].id
  }

  tags = { Name = "kwam-platform-public" }
}

resource "aws_route_table_association" "public" {
  count = local.service_count * 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_security_group" "load_balancer" {
  count = local.service_count

  name        = "kwam-platform-alb"
  description = "Public HTTP entry point for the portfolio service"
  vpc_id      = aws_vpc.platform[0].id

  ingress {
    description = "Public HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Forward requests to the service"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.platform[0].cidr_block]
  }
}

resource "aws_security_group" "service" {
  count = local.service_count

  name        = "kwam-platform-service"
  description = "Only the load balancer can reach the application"
  vpc_id      = aws_vpc.platform[0].id

  ingress {
    description     = "Application traffic from the load balancer"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer[0].id]
  }

  egress {
    description = "Pull images and send logs over HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
