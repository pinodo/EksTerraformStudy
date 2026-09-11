# data 블록이 제공하는 결과
# {
#   "names": [
#     "ap-northeast-2a",
#     "ap-northeast-2b",
#     "ap-northeast-2c",
#     "ap-northeast-2d"
#   ],
#   "zone_ids": [
#     "apne-az1",
#     "apne-az2",
#     "apne-az3",
#     "apne-az4"
#   ]
# }

# 클라우드에 존재하는 정보/메타데이터 읽어 오는 블록
data "aws_availability_zones" "available" {
  # 조회 조건(필터링)
  state = "available"
}

# 1. VPC 생성
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# 2. 인터넷 게이트웨이(IGW)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 3. Public Subnet (2개의 AZ)
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.public_subnet_cidrs[count.index]

  # 공인 IP 자동 할당
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${data.aws_availability_zones.available.names[count.index]}"
    # AWS EKS에서 퍼블릭 로드밸런서(ALB)를 생성하기 위한 필수 태그
    "kubernetes.io/role/elb" = "1"
  }
}

# 4. Private Subnet (2개의 AZ)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.private_subnet_cidrs[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${data.aws_availability_zones.available.names[count.index]}"
    # AWS EKS에서 내부 로드밸런서(ALB)를 생성하기 위한 필수 태그
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# 5. NAT Gateway EIP (탄력적 IP)
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# 6. NAT Gateway
resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public[0].id
  allocation_id = aws_eip.nat_eip.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project_name}-nat-gw"
  }
}

# 7. Public 라우트 테이블
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# 8. Public 라우트 테이블 연결
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 9. Private 라우트 테이블
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# 10. Private 라우트 테이블 연결
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}