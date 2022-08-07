# Vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "TerraformVpc"
  }
}

# IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MainInternetGateway"
  }
}

# NAT Gateway
resource "aws_eip" "nat_gateway_0" {
  vpc = true
  depends_on = [
    aws_internet_gateway.main
  ]
}
resource "aws_eip" "nat_gateway_1" {
  vpc = true
  depends_on = [
    aws_internet_gateway.main
  ]
}
resource "aws_nat_gateway" "nat_gateway_0" {
  allocation_id = aws_eip.nat_gateway_0.id
  subnet_id = aws_subnet.public_0.id
  depends_on = [
    aws_internet_gateway.main
  ]
}
resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id = aws_subnet.public_1.id
  depends_on = [
    aws_internet_gateway.main
  ]
}

# Public Subnets
resource "aws_subnet" "public_0" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet0"
  }
}
resource "aws_subnet" "public_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet1"
  }
}
resource "aws_route_table_association" "public_0"{
  subnet_id = aws_subnet.public_0.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_1"{
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "PublicSubnet-RouteTable"
  }
}
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

# Private Subnets
resource "aws_subnet" "private_0" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "PrivateSubnet0"
  }
}
resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "PrivateSubnet1"
  }
}
resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "PrivateSubnet-RouteTable0"
  }
}
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "PrivateSubnet-RouteTable1"
  }
}
resource "aws_route_table_association" "private_0"{
  subnet_id = aws_subnet.private_0.id
  route_table_id = aws_route_table.private_0.id
}
resource "aws_route_table_association" "private_1"{
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}
resource "aws_route" "private_0" {
  route_table_id = aws_route_table.private_0.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_0.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route" "private_1" {
  route_table_id = aws_route_table.private_1.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  destination_cidr_block = "0.0.0.0/0"
}