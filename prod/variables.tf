variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type = string
}

variable "vpc_name" {
  description = "Name of the vpc"
  type = string
}

variable "web_sg_name" {
  description = "Name of the web sg name"
  type = string
}

variable "backend_sg_name" {
  description = "Name of the backedn sg name"
  type = string
}

variable "private_subnet_cidr" {
  description = "private subnet cidr"
  type = string
}

variable "public_subnet_cidr" {
  description = "public subnet cidr"
  type=string
}