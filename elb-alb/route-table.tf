resource "aws_route_table" "rt_main" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = var.practice_tag
    Lab  = var.practice_tag
  }
}

resource "aws_route_table_association" "rt_ass_1a" {
  subnet_id      = aws_subnet.pub_subnet_1a.id
  route_table_id = aws_route_table.rt_main.id
}

resource "aws_route_table_association" "rt_ass_1b" {
  subnet_id      = aws_subnet.pub_subnet_1b.id
  route_table_id = aws_route_table.rt_main.id
}