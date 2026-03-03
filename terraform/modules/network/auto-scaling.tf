resource "aws_autoscaling_group" "asg" {
  min_size         = 2
  max_size         = 5
  desired_capacity = 2

  vpc_zone_identifier =[for subnet in aws_subnet.private_subnet : subnet.id]

  launch_template {
    id      = aws_launch_template.custom.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.instance_tg.id
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "Name"
    value               = "app-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_util" {
  name                   = "cpu-utilization-target"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}

