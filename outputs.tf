output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.main.id
}

output "aws_region" {
  value = var.aws_region
}

output "vm_pip" {
  value = aws_instance.main.public_ip
}
