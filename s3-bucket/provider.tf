terraform {
  required_version = "1.4.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.65.0"
    }
  }
}

provider "aws" {
  region     = var.region
  shared_credentials_files = ["/root/.aws/credentials"]
}
