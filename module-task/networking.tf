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

# Subnet Group for RDS DB
resource "aws_db_subnet_group" "dbSubnetGroup" {
  name = "RDS Subnet Group"
  subnet_ids = [module.networking.private_subnets[3],module.networking.private_subnets[4],module.networking.private_subnets[5]]
}

# Subnet Group for Web Tier
resource "aws_security_group" "web_sg" {
    name = "ALB Security Group"
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

# Subnet Group for App Tier
resource "aws_security_group" "app_sg" {
  name = "ASG Security Group"
  vpc_id = module.networking.vpc_id
    ingress = [ {
        cidr_blocks = [ ]
        description = "Allow Inbound Traffic from Web Tier"
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

# Subnet Group for DB Tier
resource "aws_security_group" "db_sg" {
    name = "DB Security Group"
    vpc_id = module.networking.vpc_id
    ingress = [ {
      cidr_blocks = [ ]
      from_port = 0
      protocol = "ALL"
      self = false
      to_port = 0
      ipv6_cidr_blocks = []
      description = "Allow Inbound from App Tier"
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