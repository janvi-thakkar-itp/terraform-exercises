module "networking" {
  source = "terraform-aws-modules/vpc/aws"

  name = "main_vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zone
  private_subnets = concat(var.app_pri_subnets, var.db_pri_subnets)
  public_subnets  = var.web_pub_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway = false

  tags = {
    Owner = var.owner
    Lab   = var.lab_tag
    Name  = var.practice_tag
  }
}

resource "aws_db_subnet_group" "dbSubnetGroup" {
  name = "rdssubnetgrp"
  subnet_ids = [module.networking.private_subnets[3],module.networking.private_subnets[4],module.networking.private_subnets[5]]
}

output "subnets"{
  value=module.networking.private_subnets
}
# #security group for DB
# resource "aws_security_group" "db_sg" {
#   name        = "allow_tls_db"
#   description = "Allow traffic in db tier"
#   vpc_id      = module.networking.vpc_id

#   ingress {
#     description      = "TLS from VPC"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     security_groups      = [aws_security_group.app_sg.id]
#   }

#   ingress {
#     description      = "TLS from VPC"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     security_groups      = [aws_security_group.app_sg.id]
#   }

#   ingress {
#     description      = "TLS from VPC"
#     from_port        = 3306
#     to_port          = 3306
#     protocol         = "TCP"
#     # security_groups      = [aws_security_group.app_sg.id]
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "allow_tls from app_sg"
#   }
# }

# #security group for APP
# resource "aws_security_group" "app_sg" {
#   name        = "allow_tls_app"
#   description = "Allow traffic in app tier"
#   vpc_id      = module.networking.vpc_id

#   ingress {
#     description      = "TLS from VPC"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     security_groups      = [aws_security_group.web_sg.id]
#   }

#   egress {
#     from_port        = 3306
#     to_port          = 3306
#     protocol         = "TCP"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        =0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }
  
#   tags = {
#     Name = "allow_tls from web_sg"
#   }
# }

# #security group for WEB
# resource "aws_security_group" "web_sg" {
#   name        = "allow_tls_web"
#   description = "Allow traffic in web tier"
#   vpc_id      = module.networking.vpc_id

#   ingress {
#     description      = "allow traffic"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   ingress {
#     description      = "allow traffic"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   ingress {
#     description      = "allow traffic"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "ALL"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }
  
#   tags = {
#     Name = "allow traffic from internet"
#   }
# }

resource "aws_security_group" "web_sg" {
    name = "ALBSecurityGroup"
    vpc_id = module.networking.vpc_id
    ingress = [ {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "Allow All Traffic"
      from_port = 0
      ipv6_cidr_blocks = [  ]
      prefix_list_ids = [  ]
      protocol = "ALL"
      security_groups = [  ]
      self = false
      to_port = 0
    } ]
    egress = [ 
        {
            cidr_blocks = [ "0.0.0.0/0" ]
            description = "Allow All Traffic"
            from_port = 0
            ipv6_cidr_blocks = [  ]
            prefix_list_ids = [  ]
            protocol = "-1"
            security_groups = [  ]
            self = false
            to_port = 0
        }
     ]
}

resource "aws_security_group" "app_sg" {
  name = "ALBSecurityGroup1"
  vpc_id = module.networking.vpc_id
    ingress = [ {
        cidr_blocks = [ ]
        description = "Allow All Traffic"
        from_port = 0
        ipv6_cidr_blocks = [  ]
        prefix_list_ids = [  ]
        protocol = "ALL"
        security_groups = [  ]
        self = false
        to_port = 0
        security_groups = [aws_security_group.web_sg.id]
    },
     ]
    egress = [ 
        {
            cidr_blocks = [ "0.0.0.0/0" ]
            description = "Allow All Traffic"
            from_port = 0
            ipv6_cidr_blocks = [  ]
            prefix_list_ids = [  ]
            protocol = "-1"
            security_groups = [  ]
            self = false
            to_port = 0
        }
     ]
}

resource "aws_security_group" "db_sg" {
    name = "DBSG"
    vpc_id = module.networking.vpc_id
    ingress = [ {
      cidr_blocks = [ ]
      from_port = 0
      protocol = "ALL"
      self = false
      to_port = 0
      ipv6_cidr_blocks = []
      description = "Allow Inbound"
      security_groups = [aws_security_group.app_sg.id]
      prefix_list_ids = []
    } ]
    egress = [ {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 0
      protocol = "ALL"
      description = "Allow Outbound"
      ipv6_cidr_blocks = []
      self = false
      security_groups = []
      prefix_list_ids = []
      to_port = 0
    } ]
}