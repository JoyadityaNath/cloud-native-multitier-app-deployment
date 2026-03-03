output "subnet_id" {
  value = {for key,subnet in aws_subnet.private_subnet:key=>subnet.id }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}


output "sg_id" {
  value = aws_security_group.http_sg.id
}


output "ami" {
  value = data.aws_ami.this.id
}


output "instance_profile"{
  value = aws_iam_instance_profile.iam_instance_profile.name
}