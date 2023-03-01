resource "aws_security_group" "elb_web" {
    vpc_id                  = aws_vpc.main_vpc.id
    name = "ELB Web Server"
    description = "ELB  Web Server"
    ingress {
        description = "Allow HTTP from anywere"
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "Allow egress traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "sg ELB Web"
        Lab = var.lab_tag
    }
}