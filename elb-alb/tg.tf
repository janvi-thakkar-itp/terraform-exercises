
resource "aws_lb_target_group" "web" {
  name        = "tg-web"
  target_type = "instance"
  protocol    = "HTTP"
  port        = "80"
  vpc_id      = aws_vpc.main_vpc.id

  health_check {
    enabled             = true
    interval            = 5
    path                = "/index.html"
    port                = 80
    protocol            = "HTTP"
    timeout             = 4
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "Target Group Web"
    Lab  = var.practice_tag
  }
}

resource "aws_lb_target_group_attachment" "web1" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "web2" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web2.id
  port             = 80
}