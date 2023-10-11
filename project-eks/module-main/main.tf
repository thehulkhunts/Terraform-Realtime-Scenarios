provider "aws" {
  region                   = "ap-south-1"
  profile                  =  "vinay"
}

terraform {
  required_version = "~>= 1.5.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>= 5.19.0"
    }
  }
}


module "module-vpc" {
  source         = "../module-vpc"
  vpc_cidr       = "10.0.0.0/16"
  subnet_cidr_01 = "10.0.1.0/24"
  subnet_cidr_02 = "10.0.2.0/24"
  private_subnet_cidr_01 = "10.0.3.0/24"
  private_subnet_cidr_02 = "10.0.4.0/24"

}

/* module "module-ec2" {
  source         = "../module-ec2"
  os             = "ami-022d03f649d12a49d"
  instance_type  = "t2.medium"
  subnet_id      = module.module-vpc.subnet-01
  security_group = module.module-sec-group.security_group
} */

module "module-sec-group" {
  source = "../module-sec-group"
  vpc_id = module.module-vpc.vpc_id
}

module "iam-role-eks" {
  source = "../iam-role-eks"
}

module "eks-cluster" {
  source                    = "../eks-cluster"
  eks-iam-role              = module.iam-role-eks.eks-iam-role
  private-subnet-01         = module.module-vpc.private-subnet-01
  private-subnet-02         = module.module-vpc.private-subnet-02
  subnet-01                 =  module.module-vpc.public-subnet-01
  subnet-02                 =  module.module-vpc.public-subnet-02
  aws-iam-policy-attachment = module.iam-role-eks.aws-iam-policy-attachment
  cluster-name              = module.eks-cluster.eks-cluster-name
  node-role                 = module.iam-role-eks.node-role
  worker-node               = module.iam-role-eks.workder-node
  eks-cni                   = module.iam-role-eks.eks-cni
  ec2-readonly              = module.iam-role-eks.ec2-readonly

}
