data "aws_ami" "this" {
  most_recent=true

  filter {
    name = "name"
    values = [ "docker-ssmagent-ecsagent-base-ubuntu22-v1" ]
  }
  owners = [ "175871674770" ]
}

data "aws_iam_role" "role" {
  name = "SSM-EC2-Role-joyanth"
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "iam_instance_profile"
  role = data.aws_iam_role.role.name
}