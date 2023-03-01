resource "aws_lb_target_group" "web" {
    name = "tg-web"
    target_type = "instance"
    protocol = "HTTP"
    port = "80"
    vpc_id = aws_vpc.main_vpc.id

    health_check {
        enabled=true
        interval = 5
        path = "/index.html"
        port = 80
        protocol = "HTTP"
        timeout = 4
        healthy_threshold = 2
        unhealthy_threshold = 3
        matcher = "200"
    }

    tags = {
        Name = "Target Group Web"
        Lab = var.lab_tag
    }
}