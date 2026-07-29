variable "web_sg_name" {
  description = "the web name of the security"
  type = string
}

variable "vpc_id" {
  description = "VPC ID from vpc module"
  type        = string
}

variable "backend_sg_name" {
  description = "the backend name of the security"
  type = string
}