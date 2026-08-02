variable "vpc_cidr" {
  description = "CIDR block for vpc"
  type=string
}

variable "vpc_name" {
    description = "Name of the vpc"
    type=string
}

variable "public_subnet_cidr" {
    description = "Public subnet CIDR"
    type = string
}


variable "private_subnet_cidr" {
   description = "Private subnet CIDR"
   type = string
}