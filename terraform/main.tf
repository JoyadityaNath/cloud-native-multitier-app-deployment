terraform {
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "6.31.0"
    }
  }
  backend "s3" {
    bucket = "devops-tf-backend-multitier-app"
    key = "state/terraform.tfstate"
    region = "ap-south-1"
    use_lockfile = true
    encrypt = true
  }
}


provider "aws" {
  region = "ap-south-1"
}


module "network" {
  source="./modules/network"
}




