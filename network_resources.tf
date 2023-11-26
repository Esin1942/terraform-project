# VPC
resource "aws_vpc" "three-tier-vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "three-tier-vpc"
  }
}

# Public Subnets 
resource "aws_subnet" "three-tier-pub-sub-1" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "three-tier-pub-sub-1"
  }
}

resource "aws_subnet" "three-tier-pub-sub-2" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.102.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "three-tier-pub-sub-2"
  }
}

resource "aws_subnet" "three-tier-pub-sub-3" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.103.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "three-tier-pub-sub-3"
  }
}


# Private Subnets
resource "aws_subnet" "three-tier-pvt-sub-1" {
  vpc_id                  = aws_vpc.three-tier-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-pvt-sub-1"
  }
}
resource "aws_subnet" "three-tier-pvt-sub-2" {
  vpc_id                  = aws_vpc.three-tier-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-pvt-sub-2"
  }
}

resource "aws_subnet" "three-tier-pvt-sub-3" {
  vpc_id                  = aws_vpc.three-tier-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-pvt-sub-3"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "three-tier-igw" {
  tags = {
    Name = "three-tier-igw"
  }
  vpc_id = aws_vpc.three-tier-vpc.id
}

# Create a Route Table
resource "aws_route_table" "three-tier-web-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-web-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three-tier-igw.id
  }
}

resource "aws_route_table" "three-tier-app-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-app-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.three-tier-natgw-01.id
  }
}


# Route Table Association
resource "aws_route_table_association" "three-tier-rt-as-1" {
  subnet_id      = aws_subnet.three-tier-pub-sub-1.id
  route_table_id = aws_route_table.three-tier-web-rt.id
}

resource "aws_route_table_association" "three-tier-rt-as-2" {
  subnet_id      = aws_subnet.three-tier-pub-sub-2.id
  route_table_id = aws_route_table.three-tier-web-rt.id
}

resource "aws_route_table_association" "three-tier-rt-as-3" {
  subnet_id      = aws_subnet.three-tier-pub-sub-3.id
  route_table_id = aws_route_table.three-tier-web-rt.id
}

resource "aws_route_table_association" "three-tier-rt-as-4" {
  subnet_id      = aws_subnet.three-tier-pvt-sub-1.id
  route_table_id = aws_route_table.three-tier-app-rt.id
}

resource "aws_route_table_association" "three-tier-rt-as-5" {
  subnet_id      = aws_subnet.three-tier-pvt-sub-2.id
  route_table_id = aws_route_table.three-tier-app-rt.id
}

resource "aws_route_table_association" "three-tier-rt-as-6" {
  subnet_id      = aws_subnet.three-tier-pvt-sub-3.id
  route_table_id = aws_route_table.three-tier-app-rt.id
}


# Create an Elastic IP address for the NAT Gateway
resource "aws_eip" "three-tier-nat-eip" {
  domain= "vpc"
}

#NatGW
resource "aws_nat_gateway" "three-tier-natgw-01" {
  allocation_id = aws_eip.three-tier-nat-eip.id
  subnet_id     = aws_subnet.three-tier-pub-sub-1.id

  tags = {
    Name = "three-tier-natgw-01"
  }
  depends_on = [aws_internet_gateway.three-tier-igw]
}