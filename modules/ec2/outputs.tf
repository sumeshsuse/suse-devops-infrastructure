output "webserver_id" {
  value = aws_instance.suse_webserver.id
}

output "backend_id" {
  value = aws_instance.suse_backend.id
}