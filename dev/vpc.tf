module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = var.vpc_name
  cidr               = var.vpc_cidr
  azs                = var.availability_zones
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  database_subnets   = var.database_subnets
  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = var.vpc_tags
}

resource "aws_security_group" "nat_sg" {
  name        = "nat-sg"
  description = "Security group for NAT instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS access from VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description = "HTTP access from VPC CIDR"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description = "All ICMP - IPv4 from VPC CIDR"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.nat_tags
}

resource "aws_instance" "nat" {
  ami           = var.nat_instance_ami
  instance_type = var.nat_instance_type
  subnet_id     = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  source_dest_check           = false
  vpc_security_group_ids      = [aws_security_group.nat_sg.id]
  tags = var.nat_tags
}

locals {
  private_route_table_map = {
    for idx, route_table_id in module.vpc.private_route_table_ids :
    idx => route_table_id
  }
}

resource "aws_route" "private_to_nat" {
  for_each = local.private_route_table_map

  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
  depends_on             = [aws_instance.nat]
}