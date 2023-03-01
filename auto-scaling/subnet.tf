resource "aws_subnet" "pub_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "192.168.${64+count.index}.0/24"
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = var.practice_tag
    Lab  = var.lab_tag
  }
  count=3
}