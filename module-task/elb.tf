# data "aws_ami" "std_ami" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

resource "aws_security_group" "ec2sg" {
  name        = "janvi-ec2-sg"
  description = "EC2 sg for terraform demo"
  vpc_id      = module.networking.vpc_id
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
  ingress {
    description = "Allowing SSH port for EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # cidr_blocks      = ["10.0.0.0/16","10.0.0.0/20"]
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
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "janvi-sg"
  }
}

resource "aws_launch_template" "launch_template" {
  name                   = "ec2-lauch"
  user_data              = base64encode(templatefile("user_data.tftpl", { db_name = module.db.db_instance_endpoint }))
  instance_type          = var.instance_type
  image_id               = var.ami_id
  key_name               = aws_key_pair.ec2Key.key_name
  vpc_security_group_ids = [aws_security_group.ec2sg.id,aws_security_group.app_sg.id]
  tags = {
    Owner = var.owner
    Lab   = var.lab_tag
    Name  = "ec2-lauch"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Owner = var.owner
      Lab   = var.lab_tag
      Name  = "ec2-lauch"
    }
  }
}

output "user_data"{
  value=aws_launch_template.launch_template.user_data
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

  # Launch template
  # launch_template_name        = aws_launch_template.launch_template.name
  # launch_template_description = aws_launch_template.launch_template.description
  # update_default_version      = true
  # instance_type          = var.instance_type
  # image_id               = var.ami_id
  
  create_launch_template = false
  launch_template        = aws_launch_template.launch_template.name
  
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
  subnets = module.networking.public_subnets[*]
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

# resource "aws_lb_target_group" "lb_target" {
#   name     = "lb-target"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = module.networking.vpc_id
# }

resource "aws_alb_target_group" "lb_target" {
  name     = "lb-target"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id
}

resource "aws_alb_listener" "aws_alb_listner" {
  load_balancer_arn = module.alb.lb_arn
  port = "80"
  protocol = "HTTP"
//  certificate_arn = var.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.lb_target.arn
    type             = "forward"
  }
}