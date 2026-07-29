resource "aws_vpc" "suse_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "suse_public_subnet" {
  vpc_id                  = aws_vpc.suse_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public"
  }
}

resource "aws_subnet" "suse_private_subnet" {
  vpc_id                  = aws_vpc.suse_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private"
  }
}

resource "aws_internet_gateway" "suse_igw" {
  vpc_id              = aws_vpc.suse_vpc.id
  tags= {
     Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "suse_public_rt" {
  vpc_id = aws_vpc.suse_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.suse_igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "suse_public_rta" {

subnet_id= aws_subnet.suse_public_subnet.id
route_table_id= aws_route_table.suse_public_rt.id

}
