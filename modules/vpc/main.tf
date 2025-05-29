# create vpc
resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc_cidr
  instance_tenancy        = "default"
  enable_dns_hostnames    = true
  enable_dns_support =  true

  tags      = {
    Name    = "${var.project_name}-vpc"
  }
}

# create private subnet pri-sub
resource "aws_subnet" "pri_sub" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.pri_sub_cidr
  availability_zone        = var.availability_zone
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "pri-sub"
  }
}

# create private route table Pri-rt
resource "aws_route_table" "pri_route_table" {
  vpc_id            = aws_vpc.vpc.id

  tags   = {
    Name = "Private-rt"
  }
}

# associate private subnet pri-sub with private route table pri_route_table
resource "aws_route_table_association" "pri-sub-with-Pri-rt" {
  subnet_id         = aws_subnet.pri_sub.id
  route_table_id    = aws_route_table.pri_route_table.id
}