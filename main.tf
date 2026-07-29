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

module "vpc" {
  source ="./modules/vpc" 
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name 
}

module "security" {
  source="./modules/security"
  vpc_id= module.vpc.vpc_id
  web_sg_name     = "suse-dev-web-sg"
  backend_sg_name = "suse-dev-backend-sg"
}

module "ec2" {
 source="./modules/ec2"
  ami               = "ami-0b826bb6d96d2afe4"
  instance_type     = "t2.micro"
  key_name          = "ssu-dev-key-pair" 
  public_subnet_id = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id
  web_sg_id = module.security.web_sg_id
  backend_sg_id = module.security.backend_sg_id
}



# resource "aws_instance" "suse_webserver" {

# ami= "ami-0b826bb6d96d2afe4"
# instance_type= "t2.micro"
# subnet_id= aws_subnet.suse_public_subnet.id
# key_name= "ssu-dev-key-pair"
# vpc_security_group_ids= [aws_security_group.suse_web_sg.id]

# tags = {

#   Name= "webserver-suse"
# }


# }


# resource "aws_instance" "suse_backend" {

# ami= "ami-0b826bb6d96d2afe4"
# instance_type= "t2.micro"
# subnet_id= aws_subnet.suse_private_subnet.id
# key_name= "ssu-dev-key-pair"
# vpc_security_group_ids= [aws_security_group.suse_backend_sg.id]

# tags = {

#   Name= "backendserver-suse"
# }


# }





