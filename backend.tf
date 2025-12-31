terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

# AWS Specific Config
# region = AWS Region where you have available GPU Quota
# profile = AWS Profile Name (When you are using AWS SSO to login)
provider "aws" {
  region = var.aws_region
  profile = var.profile_name
}
