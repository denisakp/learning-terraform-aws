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
  access_key = var.credentials.access_key
  secret_key = var.credentials.secret_key
}