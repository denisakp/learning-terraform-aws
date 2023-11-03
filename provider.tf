terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  cloud {
    organization = "akpagnonited"
    workspaces {
      name = "learning-terraform-aws"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}