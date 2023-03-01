resource "aws_internet_gateway" "ig" {
  vpc_id                  = aws_vpc.main_vpc.id
  tags = {
    Name = var.practice_tag
    Lab  = var.lab_tag
  }
}