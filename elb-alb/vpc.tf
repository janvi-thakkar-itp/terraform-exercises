# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.practice_tag
    Lab  = var.practice_tag
  }
}