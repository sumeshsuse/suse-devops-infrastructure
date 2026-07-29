output "vpc_id" {
    description = "ID of the VPC"
    value = aws_vpc.suse_vpc.id
}

output "public_subnet_id" {
    value = aws_subnet.suse_public_subnet.id  
}

output "private_subnet_id" {
  value = aws_subnet.suse_private_subnet.id
}