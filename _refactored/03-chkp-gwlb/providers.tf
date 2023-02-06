terraform {
  required_version = ">= 1.1.9"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.24.1"
    }
        random = {
      source = "hashicorp/random"
      version = "~> 3.0.1"
    }
  }
}

provider "aws" {
  region     = var.region
  #access_key = var.access_key
  #secret_key = var.secret_key
}
