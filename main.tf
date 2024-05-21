module "label" {
  source = "cloudposse/label/null"
  version = "0.24.0"
  tags   = var.tags
}

resource "aws_vpc" "myvpu-demo" {
  cidr_block       = var.vpc_cidr
  tags = module.label.tags
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpu-demo.id

  tags = {
    Name = "igw"
  }
}
resource "aws_subnet" "main" {
  count = length(var.subnets_cidr)
  vpc_id     = aws_vpc.myvpu-demo.id
  cidr_block = element(var.subnets_cidr , count.index)
  availability_zone = var.azs
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Subnet-${count.index +1}"
  }
}
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpu-demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "mypublicRT"
  }
}
resource "aws_route_table_association" "RTA" {
  count = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.main.*.id, count.index)
  route_table_id = aws_route_table.RT.id
}
resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.main[0].id # Assuming the NAT gateway is in the first subnet
}

resource "aws_route_table" "private_RT" {
  vpc_id = aws_vpc.myvpu-demo.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "privateRT"
  }
}
