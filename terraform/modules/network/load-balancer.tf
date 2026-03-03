resource "aws_lb" "app_load_balancer" {
  name = "app-load-balancer"
  internal = false
  security_groups = [ aws_security_group.http_sg.id ]
  subnets = [ for subnet in aws_subnet.public_subnet:subnet.id ]
}



resource "aws_security_group" "http_sg" {
    name = "allow_http"
    description = "Allow internet traffic belonging to HTTP traffic on Port 80"
    vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  security_group_id = aws_security_group.http_sg.id
  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.http_sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_lb_target_group" "instance_tg" {
  name     = "tf-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  ip_address_type = "ipv4"
}



resource "aws_lb_listener" "name" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port = "80"
  default_action {
    target_group_arn = aws_lb_target_group.instance_tg.arn
    type = "forward"
  }
}


resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.name.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance_tg.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

