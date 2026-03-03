packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "docker-ssmagent-base-ubuntu22-v1"
  instance_type = "t3.small"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}


build {
  name    = "docker-ssmagent-base-ubuntu22-v1"
  sources = ["source.amazon-ebs.ubuntu"]


provisioner "shell" {
  # Docker installation
  script="docker-install.sh"
  execute_command="sudo -E bash '{{.Path}}'"
}
provisioner "shell" {
  # SSM Agent installation
  script="ssm-agent.sh"
  execute_command="sudo -E bash '{{.Path}}'"
}
} 