provider "aws" {
  region = var.aws_region   # FIX 1: Remove quotes, use variable
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # THIS IS THE BACKEND CONFIGURATION
  backend "s3" {
    bucket         = "raj-ecommerce-state-2026-v2"
    key            = "ecommerce/terraform.tfstate"
    region         = "ap-south-1"             # FIX 2: MUST be hardcoded string
    dynamodb_table = "ecommerce-terraform-lock"
    encrypt        = true
  }
}
