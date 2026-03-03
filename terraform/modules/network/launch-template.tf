resource "aws_launch_template" "custom" {
  name = "docker-ssm-template-asg"
  image_id = data.aws_ami.this.id
  instance_type = "t3.small"
  monitoring {
    enabled = true
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.iam_instance_profile.name
  }
  vpc_security_group_ids = [ aws_security_group.launch_temp_sg.id ]

}


resource "aws_security_group" "launch_temp_sg" {
  name = "Allow http to EC2"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "HTTP-Allow-EC2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id = aws_security_group.launch_temp_sg.id
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
  referenced_security_group_id = aws_security_group.http_sg.id
}


resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.launch_temp_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}



