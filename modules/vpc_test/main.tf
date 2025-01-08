# VPC 생성
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "main-vpc"
  })
}

# 퍼블릭 서브넷 생성 (AZ 별로)
resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.public_subnet_cidr, 3, count.index)
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "public-subnet-${var.availability_zones[count.index]}"
  })
}

# 프라이빗 서브넷 생성 (AZ 별로)
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.private_subnet_cidr, 3, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "private-subnet-${var.availability_zones[count.index]}"
  })
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "main-igw"
  })
}

# 퍼블릭 라우트 테이블 생성
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "public-route-table"
  })
}

# 퍼블릭 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT 인스턴스 생성
resource "aws_instance" "nat" {
  ami                         = var.nat_ami
  instance_type               = var.nat_instance_type
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = var.key_name
  associate_public_ip_address = true
  source_dest_check           = false
  vpc_security_group_ids      = [var.nat_security_group_id]

  tags = merge(var.tags, {
    Name = "nat-instance"
  })
}

# 프라이빗 라우트 테이블 생성
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "private-route-table"
  })
}

# 프라이빗 라우트 테이블에 NAT 인스턴스 라우트 추가
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}

# 프라이빗 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}