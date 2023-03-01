resource "aws_lb" "web" {
    name = "WebFront"
    internal = false
    load_balancer_type = "application"
    ip_address_type = "ipv4"
   
    security_groups = [aws_security_group.elb_web.id]

    subnets = aws_subnet.pub_subnet[*].id 

    tags = {
        Name = "Elastic Load Balancer Web"
        Lab = var.lab_tag
    }
}

resource "aws_lb_listener" "Web80" {
    load_balancer_arn = aws_lb.web.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.web.arn
    }
}