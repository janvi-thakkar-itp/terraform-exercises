module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "5.6.0"
  identifier = "rds-db"

  engine            = "mysql"
  instance_class    = "db.t2.micro"
  allocated_storage = 10
  max_allocated_storage = 10

  create_random_password = false
  db_name                             = "rdsDb"
  username                            = "user"
  password                            = "password"
  port=3306
  iam_database_authentication_enabled = true
  availability_zone = var.availability_zone[0]
  create_db_option_group = false
  create_db_parameter_group = false
  create_db_subnet_group = false
  
  storage_type = "gp2"
  storage_encrypted = false
  publicly_accessible = false

  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Owner       = var.owner
    Environment = "dev"
  }

  db_subnet_group_name = aws_db_subnet_group.dbSubnetGroup.name
  subnet_ids             = [module.networking.private_subnets[3],module.networking.private_subnets[4],module.networking.private_subnets[5]]
  skip_final_snapshot = true
}

# module "rds" {
#   source  = "terraform-aws-modules/rds/aws"
#   version = "5.6.0"

#   identifier = "vishalassignrds"
#   db_name = "assignmentDB"
#   password = "Hk12267171"
#   username = "rdsRoot"
#   port = 3306
#   availability_zone = data.aws_availability_zones.az.names[0]
#   create_db_option_group = false
#   create_db_parameter_group = false
#   create_db_subnet_group = false
#   create_random_password = false
#   skip_final_snapshot = true
#   instance_class = "db.t2.micro"
#   allocated_storage = 10
#   max_allocated_storage = 10
#   storage_type = "gp2"
#   storage_encrypted = false
#   publicly_accessible = false
#   engine = "mysql"
#   tags = {
#       "Name" = "RDS Assignment"
#       "Owner" = "harshil.khamar@intuitive.cloud"
#     }
#   db_subnet_group_name = aws_db_subnet_group.dbSubnetGroup.name
#   subnet_ids = aws_db_subnet_group.dbSubnetGroup.*.id
#   vpc_security_group_ids = [ aws_security_group.dbSG.id]
# }

output "rds-output" {
  value = module.db.db_instance_address
}

# output "pass" {
#   value= module.db.db_instance_password
#   sensitive=false
# }