resource "aws_subnet" "pub_subnet_1a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.0.128/28"
  availability_zone = "us-east-1a"

  tags = {
    Name = var.practice_tag
    Lab  = var.practice_tag
  }
}

resource "aws_subnet" "pub_subnet_1b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.0.192/28"
  availability_zone = "us-east-1b"

  tags = {
    Name = var.practice_tag
    Lab  = var.practice_tag
  }
}