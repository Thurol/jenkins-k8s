terraform {
  backend "local" {
    path = "terraform.tfstate"
  }

  required_version = "~> 1.8.4"

  required_providers {
    aws = {
      version = "~> 4.67.0"
      source  = "hashicorp/aws"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}
