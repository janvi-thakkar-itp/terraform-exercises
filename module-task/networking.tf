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

# #eip for nat_gateway
# resource "aws_eip" "eip" {
#   tags = {
#     Owner = var.owner
#   }
# }

# #nat_gateway
# resource "aws_nat_gateway" "nat_gtw" {
#   allocation_id = aws_eip.eip.id
#   subnet_id     = module.networking.public_subnets[0]

#   tags = {
#     Name = "gw NAT"
#   }
# }


#security group for DB
resource "aws_security_group" "db_sg" {
  name        = "allow_tls_db"
  description = "Allow traffic in db tier"
  vpc_id      = module.networking.vpc_id
# ingress = [ {
#     cidr_blocks = [ "0.0.0.0/0" ]
#     description = "value"
#     from_port = 0
#     ipv6_cidr_blocks = [ ]
#     prefix_list_ids = [  ]
#     protocol = "ALL"
#     self = false
#     to_port = 0
#     security_groups = []
#   } ]
#   egress = [ {
#     cidr_blocks = [ "0.0.0.0/0" ]
#     description = "value"
#     from_port = 0
#     ipv6_cidr_blocks = [ ]
#     prefix_list_ids = [  ]
#     protocol = "ALL"
#     self = false
#     to_port = 0
#     security_groups = []
#   } ]
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups      = [aws_security_group.app_sg.id]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups      = [aws_security_group.app_sg.id]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups      = [aws_security_group.app_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls from app_sg"
  }
}

#security group for APP
resource "aws_security_group" "app_sg" {
  name        = "allow_tls_app"
  description = "Allow traffic in app tier"
  vpc_id      = module.networking.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups      = [aws_security_group.web_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  # ingress = [ {
  #   cidr_blocks = [ "0.0.0.0/0" ]
  #   description = "value"
  #   from_port = 0
  #   ipv6_cidr_blocks = [ ]
  #   prefix_list_ids = [  ]
  #   protocol = "ALL"
  #   self = false
  #   to_port = 0
  #   security_groups = []
  # } ]
  # egress = [ {
  #   cidr_blocks = [ "0.0.0.0/0" ]
  #   description = "value"
  #   from_port = 0
  #   ipv6_cidr_blocks = [ ]
  #   prefix_list_ids = [  ]
  #   protocol = "ALL"
  #   self = false
  #   to_port = 0
  #   security_groups = []
  # } ]

  tags = {
    Name = "allow_tls from web_sg"
  }
}

#security group for WEB
resource "aws_security_group" "web_sg" {
  name        = "allow_tls_web"
  description = "Allow traffic in web tier"
  vpc_id      = module.networking.vpc_id

  ingress {
    description      = "allow traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "allow traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "allow traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  # ingress = [ {
  #   cidr_blocks = [ "0.0.0.0/0" ]
  #   description = "value"
  #   from_port = 0
  #   ipv6_cidr_blocks = [ ]
  #   prefix_list_ids = [  ]
  #   protocol = "ALL"
  #   self = false
  #   to_port = 0
  #   security_groups = []
  # } ]
  # egress = [ {
  #   cidr_blocks = [ "0.0.0.0/0" ]
  #   description = "value"
  #   from_port = 0
  #   ipv6_cidr_blocks = [ ]
  #   prefix_list_ids = [  ]
  #   protocol = "ALL"
  #   self = false
  #   to_port = 0
  #   security_groups = []
  # } ]
  tags = {
    Name = "allow traffic from internet"
  }
}