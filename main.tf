terraform {
  backend "s3" {
    bucket         = "suse-terraform-state-2026"
    key            = "suse/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "suse-terraform-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "suse_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "suse-vpc"
  }
}

resource "aws_subnet" "suse_public_subnet" {
  vpc_id                  = aws_vpc.suse_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "suse-subnet-public"
  }
}

resource "aws_subnet" "suse_private_subnet" {
  vpc_id                  = aws_vpc.suse_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "suse-subnet-private"
  }
}

resource "aws_internet_gateway" "suse_igw" {
  vpc_id              = aws_vpc.suse_vpc.id
  tags= {
     Name = "suse-internet-gateway"
  }
}

resource "aws_route_table" "suse_public_rt" {
  vpc_id = aws_vpc.suse_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.suse_igw.id
  }

  tags = {
    Name = "suse-public-rt"
  }
}

resource "aws_route_table_association" "suse_public_rta" {

subnet_id= aws_subnet.suse_public_subnet.id
route_table_id= aws_route_table.suse_public_rt.id

}


resource "aws_security_group" "suse_web_sg" {
  name        = "suse-dev-web-sg"
  description = "Security group for web server"
  vpc_id      = aws_vpc.suse_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "suse-dev-web-sg"
  }
}

resource "aws_security_group" "suse_backend_sg" {
  name        = "suse-dev-backend-sg"
  description = "Security group for backend server"
  vpc_id      = aws_vpc.suse_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.suse_web_sg.id]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.suse_web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "suse-dev-backend-sg"
  }
}

resource "aws_instance" "suse_webserver" {

ami= "ami-0b826bb6d96d2afe4"
instance_type= "t2.micro"
subnet_id= aws_subnet.suse_public_subnet.id
key_name= "ssu-dev-key-pair"
vpc_security_group_ids= [aws_security_group.suse_web_sg.id]

tags = {

  Name= "webserver-suse"
}


}


resource "aws_instance" "suse_backend" {

ami= "ami-0b826bb6d96d2afe4"
instance_type= "t2.micro"
subnet_id= aws_subnet.suse_private_subnet.id
key_name= "ssu-dev-key-pair"
vpc_security_group_ids= [aws_security_group.suse_backend_sg.id]

tags = {

  Name= "backendserver-suse"
}


}





