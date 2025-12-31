variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vm_ami" {
  type    = string
  default = "ami-0bc9cd397e1bc6ae3" # Ubuntu 22.04 - Deep Learning Base AMI with Single CUDA
}

variable "vm_instance_type" {
  type    = string
  default = "g5.xlarge"
}

variable "profile_name" {
    type = string
}

variable "project_name" {
  type = string
}

# You will use SSH to log in, please enter SSH public key here
variable "public_key_path" {
  type = string
  # default = "/home/user/.ssh/genericaws.pub"
}