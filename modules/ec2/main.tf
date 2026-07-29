resource "aws_instance" "suse_webserver" {

ami= var.ami
instance_type= var.instance_type
subnet_id= var.public_subnet_id
key_name= var.key_name
vpc_security_group_ids= [var.web_sg_id]

tags = {

  Name= "webserver-suse"
}

}

resource "aws_instance" "suse_backend" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.backend_sg_id]

  tags = {
    Name = "backendserver-suse"
  }
}