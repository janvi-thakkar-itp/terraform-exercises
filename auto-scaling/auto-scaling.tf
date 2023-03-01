resource "aws_autoscaling_group" "as_grp" {
    name = "WebASG"    
    launch_configuration = aws_launch_configuration.as_conf.id

    max_size = 6
    min_size = 3

    target_group_arns = [aws_lb_target_group.web.arn]
    vpc_zone_identifier = aws_subnet.pub_subnet[*].id 

    tags = [ 
    {
        "key" = "Name" 
        "value" = "Autoscaling group Web"
        "propagate_at_launch" = true
    },
    {
        "key" = "Lab" 
        "value" = var.lab_tag
        "propagate_at_launch" = true
    } ]
}

resource "aws_autoscaling_policy" "as_pol_cpu" {
    name = "ASG-policy-cpu"
    autoscaling_group_name = aws_autoscaling_group.as_grp.name 
    policy_type = "TargetTrackingScaling"
    estimated_instance_warmup = 120

    target_tracking_configuration {
            predefined_metric_specification {
                predefined_metric_type = "ASGAverageCPUUtilization"
            }
            target_value = 50
    }
}