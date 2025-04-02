terraform {
  backend "s3" {
    bucket = "devops-tools-cache"
    region = "ap-southeast-1"
    key    = "terraform/devops.tfstate"
  }
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
}
