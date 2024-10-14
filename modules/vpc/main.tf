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
  for_each          = toset(var.availability_zones)  # 각 AZ에 대해 서브넷 생성
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.public_subnet_cidr, 3, index(var.availability_zones, each.key))
  availability_zone = each.key
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "public-subnet-${each.key}"
  })
}

# 프라이빗 서브넷 생성 (AZ 별로)
resource "aws_subnet" "private" {
  for_each          = toset(var.availability_zones)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.private_subnet_cidr, 3, index(var.availability_zones, each.key))
  availability_zone = each.key

  tags = merge(var.tags, {
    Name = "private-subnet-${each.key}"
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

# 퍼블릭 서브넷과 라우트 테이블 연결 (AZ 별로)
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT 인스턴스용 보안 그룹 생성
resource "aws_security_group" "nat_sg" {
  name        = "nat-instance-sg"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.this.id

  # 인바운드 규칙 1: SSH 접근 (전 세계에서)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 허용 (보안을 위해 특정 IP로 제한 가능)
  }

  # 인바운드 규칙 2: HTTPS (VPC CIDR 범위에서)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]  # VPC CIDR에서만 접근 허용
  }

  # 인바운드 규칙 3: HTTP (VPC CIDR 범위에서)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]  # VPC CIDR에서만 접근 허용
  }

  # 인바운드 규칙 4: 모든 ICMP - IPv4 (VPC CIDR 범위에서)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.this.cidr_block]  # VPC CIDR에서만 ICMP 허용
  }

  # 모든 아웃바운드 트래픽 허용 (NAT 인스턴스가 인터넷에 접근할 수 있도록)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "nat-instance-sg"
  })
}

# NAT 인스턴스 생성 (하나만 생성)
resource "aws_instance" "nat" {
  ami               = var.nat_ami                     # NAT 인스턴스용 AMI
  instance_type     = var.nat_instance_type           # NAT 인스턴스 타입
  subnet_id         = values(aws_subnet.public)[0].id # 첫 번째 퍼블릭 서브넷에 배치
  key_name          = var.key_name                    # SSH 접근을 위한 키 페어
  associate_public_ip_address = true                  # 퍼블릭 IP 할당
  source_dest_check = false                           # NAT 인스턴스에서는 소스/대상 확인 비활성화
  vpc_security_group_ids = [aws_security_group.nat_sg.id]  # NAT 인스턴스 보안 그룹 연결

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

# 프라이빗 라우트 테이블에 NAT 인스턴스 라우트 추가 (모든 프라이빗 서브넷이 하나의 NAT 인스턴스를 사용)
resource "aws_route" "private_nat_route" {
  count                  = length(aws_subnet.private)
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}

# 프라이빗 서브넷과 프라이빗 라우트 테이블 연결 (AZ 별로)
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}