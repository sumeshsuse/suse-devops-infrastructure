output "web_sg_id" {
  value = aws_security_group.suse_web_sg.id
}

output "backend_sg_id" {
  value= aws_security_group.suse_backend_sg.id
}