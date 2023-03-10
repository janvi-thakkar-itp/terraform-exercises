module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "rds-db"

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t2.large"
  allocated_storage = 5

  db_name                             = "rdsDb"
  username                            = "user"
  port                                = "3306"
  password                            = "password"
  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.db_sg.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = {
    Owner       = var.owner
    Environment = "dev"
  }

 # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = [module.networking.private_subnets[0],module.networking.private_subnets[1]]

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = false

  # parameters = [
  #   {
  #     name = "log_connection"
  #     value=1
  #   }
  # ]
}

output "rds-output" {
  value = module.db.db_instance_endpoint
}