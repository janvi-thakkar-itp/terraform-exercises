#Application Load Balancer
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name = "${var.practice_tag}-alb"

  load_balancer_type = "application"

  vpc_id          = module.networking.vpc_id
  subnets         = module.networking.public_subnets
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Owner = var.owner
    Lab   = var.lab_tag
    Name  = "${var.practice_tag}-alb"
  }
}

#Auto-Scaling Group
module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name                = "${var.practice_tag}-asg"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 2
  health_check_type   = "EC2"
  vpc_zone_identifier = module.networking.public_subnets

  #lauch template
  launch_template_name        = "${var.practice_tag}-ec2-lauch"
  launch_template_description = "ec2 launch template"
  user_data                   = base64encode(templatefile("user_data.tftpl", { db_name = module.db.db_instance_address }))
  instance_type               = var.instance_type
  image_id                    = var.ami_id
  key_name                    = aws_key_pair.ec2Key.key_name
  security_groups             = [aws_security_group.app_sg.id]

  #EC2 tags
  tag_specifications = [
    {
      resource_type = "instance"
      tags = {
        Owner = var.owner
        Lab   = var.lab_tag
        Name  = "${var.practice_tag}-ec2"
      }
    }
  ]

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
    Name  = "${var.practice_tag}-asg"
  }
}

#EC2 Key Pair
resource "aws_key_pair" "ec2Key" {
  public_key = file("ec2.pub")
  key_name   = "ec2KeyPair"

  tags = {
    Owner = var.owner
    Lab   = var.lab_tag
    Name  = "${var.practice_tag}-keypair"
  }
}


# ALB Target Group Resource 
resource "aws_alb_target_group" "lb_target" {
  name     = "${var.practice_tag}-lb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.networking.vpc_id

  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

  tags = {
    Owner = var.owner
    Lab   = var.lab_tag
    Name  = "${var.practice_tag}-alb-tg"
  }
}

# ALB Target Group Listner
resource "aws_alb_listener" "aws_alb_listner" {
  load_balancer_arn = module.alb.lb_arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.lb_target.arn
    type             = "forward"
  }

  tags = {
    Owner = var.owner
    Lab   = var.lab_tag
    Name  = "${var.practice_tag}-alb-listner"
  }
}

#Auto Scaling Attachment as ALB Target Group
resource "aws_autoscaling_attachment" "asg_attachment_elb" {
  autoscaling_group_name = module.asg.autoscaling_group_id
  alb_target_group_arn   = aws_alb_target_group.lb_target.arn
}

