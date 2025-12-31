resource "aws_instance" "main" {
  ami                    = var.vm_ami
  instance_type          = var.vm_instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.main.key_name

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = 256
  }

  tags = {
    Name      = "${var.project_name}_lab_vm01"
    Terraform = "true"
    Project   = "${var.project_name}"
  }
}
