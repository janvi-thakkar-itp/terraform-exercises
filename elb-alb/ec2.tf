resource "aws_instance" "web1" {
    ami = var.instance_ami
    instance_type = var.instance_type
    depends_on = [
      aws_security_group.web_sg,
      aws_subnet.pub_subnet_1a, 
      aws_vpc.main_vpc
    ]
    key_name = aws_key_pair.lab.id

    user_data = var.web_user_data

    subnet_id      = aws_subnet.pub_subnet_1a.id
    vpc_security_group_ids = [ aws_security_group.web_sg.id ]

    root_block_device {
        volume_size = 8
        delete_on_termination = true
    }
     
    tags = {
        Name = "Web1"
        Lab = var.practice_tag
    }
    volume_tags = {
        Name = "Web1"
        Lab = var.practice_tag
    }
}

resource "aws_instance" "web2" {
    ami = var.instance_ami
    instance_type = var.instance_type
    depends_on = [
      aws_security_group.web_sg,
      aws_subnet.pub_subnet_1b, 
      aws_vpc.main_vpc
    ]
    key_name = aws_key_pair.lab.id

    user_data = var.web_user_data

    subnet_id      = aws_subnet.pub_subnet_1b.id
    vpc_security_group_ids = [ aws_security_group.web_sg.id ]

    root_block_device {
        volume_size = 8
        delete_on_termination = true
    }
     
    tags = {
        Name = "Web2"
        Lab = var.practice_tag
    }
    volume_tags = {
        Name = "Web2"
        Lab = var.practice_tag
    }
}