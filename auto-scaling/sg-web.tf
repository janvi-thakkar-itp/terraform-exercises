resource "aws_security_group" "web_server" {
    vpc_id                  = aws_vpc.main_vpc.id
    name = "SG Web Server"
    description = "SG Web Server"
    ingress {
        description = "Allow HTTP from anywere"
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow SSH from anywere"
        from_port = 22
        to_port = 22
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
        Name = "SG Web Server"
        Lab = var.lab_tag
    }
}