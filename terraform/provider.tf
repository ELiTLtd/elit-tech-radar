terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.1"
    }
  }

  backend "s3" {
    bucket         = "elit-infrastructure-by-service"
    key            = "prod-eu-west-1-tech-radar.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

# Default provider in eu-west-1 for state management
provider "aws" {
  region              = "eu-west-1"
  allowed_account_ids = local.allowed_account_ids

  default_tags {
    tags = local.default_tags
  }
}

# Provider for CloudFront and US-based resources
provider "aws" {
  alias               = "us_east_1"
  region              = "us-east-1"
  allowed_account_ids = local.allowed_account_ids

  default_tags {
    tags = local.default_tags
  }
}

# Common locals that need to be available for both files
locals {
  allowed_account_ids = ["689917379567"]
  default_tags        = {
    Terraform     = "true"
    TerraformRepo = "ELiTLtd/elit-tech-radar"
    ServiceName   = "elit-tech-radar"
  }
}
