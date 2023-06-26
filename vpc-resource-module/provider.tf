terraform {
  required_version = "1.5.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.65.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  shared_credentials_files = ["root/.aws/credentials"]
}
