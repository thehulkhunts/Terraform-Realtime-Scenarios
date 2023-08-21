provider "aws" {
  region                   = var.region
  shared_credentials_files = ["/root/.aws/credentials"]
}

terraform {
  required_version = "1.5.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.65.0"
    }
  }
}

module "module-vpc" {
  source         = "../module-vpc"
  vpc_cidr       = "10.0.0.0/16"
  subnet_cidr-01 = "10.0.1.0/24"
  subnet_cidr-02 = "10.0.2.0/24"
  subnet_cidr-03 = "10.0.3.0/24"
  subnet_cidr-04 = "10.0.4.0/24"
  az             = "ap-south-1a"
  az-02          = "ap-south-1b"
}

module "module-autoscaling" {
  source        = "../module-autoscaling"
  vpc_id        = module.module-vpc.vpc
  subnet-01     = module.module-vpc.subnet-01
  subnet-02     = module.module-vpc.subnet-02
  pvt-subnet-03 = module.module-vpc.pvt-subnet-01
  pvt-subnet-04 = module.module-vpc.pvt-subnet-02
}
