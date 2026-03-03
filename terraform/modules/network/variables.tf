variable "public_subnet_credentials" {
  type = map(object({
    cidr_block = string
    availability_zone=string
  }))
  default = {
    "az1" = {
      cidr_block="10.0.0.0/24",
      availability_zone="ap-south-1a"
    }
    "az2" = {
      cidr_block="10.0.1.0/24",
      availability_zone="ap-south-1b"
    }
  }
}


variable "private_subnet_credentials" {
  type = map(object({
    cidr_block = string
    availability_zone=string
  }))
  default = {
    "az1" = {
      cidr_block="10.0.2.0/24",
      availability_zone="ap-south-1a"
    }
    "az2" = {
      cidr_block="10.0.3.0/24",
      availability_zone="ap-south-1b"
    }
  }
}


variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}


