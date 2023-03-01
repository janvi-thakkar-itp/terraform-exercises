resource "aws_route_table" "rt_main" {
  vpc_id                  = aws_vpc.main_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = var.practice_tag
    Lab  = var.lab_tag
  }
}

resource "aws_route_table_association" "rt_ass_us_east" {
  subnet_id      = aws_subnet.pub_subnet[count.index].id
  route_table_id = aws_route_table.rt_main.id 
  count=3
}