output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "web_sg_id" {
    description = "ID of the web sg id"
    value = module.security.web_sg_id  
}

output "backend_sg_id" {
  description = "ID of the backend sg id "
  value = module.security.backend_sg_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

