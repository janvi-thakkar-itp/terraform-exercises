
resource "aws_security_group" "ec2sg" {
  name        = "janvi-ec2-sg"
  description = "EC2 sg for terraform demo"
  vpc_id      = module.networking.vpc_id
  
  ingress {
    description = "Allowing SSH port for EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allowing HTTP port for EC2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "janvi-sg"
  }
}

resource "aws_key_pair" "ec2Key" {
  public_key = file("ec2.pub")
  key_name = "ec2KeyPair"
}

resource "aws_autoscaling_attachment" "asg_attachment_elb" {
  autoscaling_group_name = module.asg.autoscaling_group_id
  alb_target_group_arn   = aws_alb_target_group.lb_target.arn
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "main_asg"

  min_size            = 2
  max_size            = 3
  desired_capacity    = 3
  health_check_type   = "EC2"
  vpc_zone_identifier = module.networking.public_subnets
  
  #lauch template
  launch_template_name                   = "ec2-lauch"
  launch_template_description            = "ec2 launch template"
  user_data              = base64encode(templatefile("user_data.tftpl", { db_name = module.db.db_instance_address }))
  instance_type          = var.instance_type
  image_id               = var.ami_id
  key_name               = aws_key_pair.ec2Key.key_name
  security_groups= [aws_security_group.app_sg.id]
  
  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = "ec2-rds-role"
  iam_role_description        = "IAM role for Ec2 to use RDS"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }

  iam_role_policies = {
    AmazonRDSFullAccess = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  }

  capacity_reservation_specification = {
  capacity_reservation_preference = "open"
  }

  placement = {
    availability_zone = var.availability_zone[0]
  }

  tags = {
    Owner = var.owner
    Lab   = var.lab_tag
    Name  = var.practice_tag
  }
}


module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name = "main-alb"

  load_balancer_type = "application"

  vpc_id  = module.networking.vpc_id
  subnets = module.networking.public_subnets
  security_groups    = [aws_security_group.web_sg.id]

  target_groups = [
    {
      name_prefix      = "elb-"
      backend_protocol = "HTTP"
      backend_port     = 80
    }
  ]


  tags = {
    Owner = var.owner
    Lab   = "${var.lab_tag}-elb"
    Name  = var.practice_tag
  }
}

resource "aws_alb_target_group" "lb_target" {
  name     = "lb-target"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id

  stickiness{
    enabled=true
    type="lb_cookie"
  }
}

resource "aws_alb_listener" "aws_alb_listner" {
  load_balancer_arn = module.alb.lb_arn
  port = "80"
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.lb_target.arn
    type             = "forward"
  }
}