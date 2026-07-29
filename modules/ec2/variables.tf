variable "ami" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID from vpc module"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID from vpc module"
  type        = string
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "web_sg_id" {
  description = "Web security group ID"
  type        = string
}

variable "backend_sg_id" {
  description = "Backend security group ID"
  type        = string
}